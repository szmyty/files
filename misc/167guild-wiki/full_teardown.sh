#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID=$(gcloud config get-value project)
ZONE="us-east1-b"
NAMESPACE="wikijs"
CLUSTERS=("dnd-wiki-cluster" "dnd-wiki-cluster-v2")
STATIC_IP_NAME="wikijs-ip"
HELM_RELEASE="dnd-wiki"
LOG_FILE="teardown.log"

trap 'echo "❌ Teardown script failed. Check $LOG_FILE for details." >&2' ERR

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') 🔹 $1" | tee -a "$LOG_FILE"
}

delete_cluster() {
  for CLUSTER in "${CLUSTERS[@]}"; do
    if gcloud container clusters describe "$CLUSTER" --zone "$ZONE" >/dev/null 2>&1; then
      log "🗑️ Deleting GKE cluster: $CLUSTER"
      gcloud container clusters delete "$CLUSTER" --zone "$ZONE" --quiet | tee -a "$LOG_FILE"
    else
      log "✅ Cluster $CLUSTER not found. Skipping."
    fi
  done
}

delete_static_ip() {
  if gcloud compute addresses describe "$STATIC_IP_NAME" --global >/dev/null 2>&1; then
    log "🗑️ Deleting reserved static IP: $STATIC_IP_NAME"
    gcloud compute addresses delete "$STATIC_IP_NAME" --global --quiet | tee -a "$LOG_FILE"
  else
    log "✅ Static IP $STATIC_IP_NAME not found."
  fi
}

delete_kube_resources() {
  if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    log "🧹 Cleaning up resources in namespace: $NAMESPACE"
    kubectl delete ingress wikijs-ingress -n "$NAMESPACE" --ignore-not-found | tee -a "$LOG_FILE"
    kubectl delete managedcertificate wikijs-cert -n "$NAMESPACE" --ignore-not-found | tee -a "$LOG_FILE"
    kubectl delete pvc -n "$NAMESPACE" --all --ignore-not-found | tee -a "$LOG_FILE"
    kubectl delete namespace "$NAMESPACE" --ignore-not-found | tee -a "$LOG_FILE"
  else
    log "✅ Namespace $NAMESPACE does not exist. Skipping."
  fi
}

uninstall_helm_release() {
  if helm status "$HELM_RELEASE" -n "$NAMESPACE" >/dev/null 2>&1; then
    log "🗑️ Uninstalling Helm release: $HELM_RELEASE"
    helm uninstall "$HELM_RELEASE" -n "$NAMESPACE" | tee -a "$LOG_FILE"
  else
    log "✅ Helm release $HELM_RELEASE not found."
  fi
}

remove_kube_contexts() {
  for CLUSTER in "${CLUSTERS[@]}"; do
    CONTEXT="gke_${PROJECT_ID}_${ZONE}_${CLUSTER}"
    if kubectl config get-contexts "$CONTEXT" >/dev/null 2>&1; then
      log "🧹 Removing kubeconfig context: $CONTEXT"
      kubectl config delete-context "$CONTEXT" | tee -a "$LOG_FILE"
    else
      log "✅ Context $CONTEXT not found."
    fi
  done
}

main() {
  log "🔧 Starting full teardown for project: $PROJECT_ID"

  if ! command -v gcloud &>/dev/null || ! command -v kubectl &>/dev/null; then
    log "❌ Missing gcloud or kubectl in PATH. Cannot proceed."
    exit 1
  fi

  delete_cluster
  delete_static_ip
  uninstall_helm_release
  delete_kube_resources
  remove_kube_contexts

  log "✅ Teardown complete. Project is clean and ready for cluster recreation."
}

main
