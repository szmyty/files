#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID=$(gcloud config get-value project)
ZONE="us-east1-b"
CLUSTER_NAME="dnd-wiki-cluster"
NAMESPACE="wikijs"
DOMAIN="wiki.167guild.io"
STATIC_IP_NAME="wikijs-ip"
LOG_FILE="verify_cluster.log"

trap 'echo "❌ Verification failed. Check $LOG_FILE for details." >&2' ERR

log() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') 🔹 $1" | tee -a "$LOG_FILE"
}

verify_kubectl() {
  log "🔍 Verifying kubectl cluster connection..."
  kubectl cluster-info | tee -a "$LOG_FILE"
}

verify_cluster_status() {
  log "🔍 Cluster status for $CLUSTER_NAME:"
  gcloud container clusters describe "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --format="yaml(name,status,currentNodeCount,addonsConfig,maintenancePolicy)" \
    | tee -a "$LOG_FILE"
}

verify_namespace() {
  log "🔍 Checking namespace: $NAMESPACE"
  kubectl get namespace "$NAMESPACE" | tee -a "$LOG_FILE"
}

verify_pods() {
  log "📦 Pod status in namespace $NAMESPACE:"
  kubectl get pods -n "$NAMESPACE" -o wide | tee -a "$LOG_FILE"
}

verify_ingress() {
  log "🌐 Ingress and TLS info:"
  kubectl get ingress -n "$NAMESPACE" -o wide | tee -a "$LOG_FILE"
  kubectl describe managedcertificate wikijs-cert -n "$NAMESPACE" | tee -a "$LOG_FILE"
}

verify_dns() {
  log "🧭 DNS resolution for $DOMAIN:"
  dig +short "$DOMAIN" | tee -a "$LOG_FILE"
}

verify_static_ip() {
  log "🌐 Verifying reserved static IP: $STATIC_IP_NAME"

  if gcloud compute addresses describe "$STATIC_IP_NAME" --global >/dev/null 2>&1; then
    IP=$(gcloud compute addresses describe "$STATIC_IP_NAME" --global --format="value(address)")
    log "✅ Static IP $STATIC_IP_NAME found: $IP"

    log "🔍 Cross-checking DNS A record for $DOMAIN:"
    DNS_IP=$(dig +short "$DOMAIN" | tail -n 1)

    if [[ "$DNS_IP" == "$IP" ]]; then
      log "✅ DNS is correctly pointing to the static IP."
    else
      log "❌ DNS mismatch: $DOMAIN → $DNS_IP (expected $IP)"
    fi
  else
    log "❌ Static IP $STATIC_IP_NAME not found."
  fi
}

main() {
  log "🔧 Starting verification for project: $PROJECT_ID"
  verify_kubectl
  verify_cluster_status
  verify_namespace
  verify_pods
  verify_ingress
  verify_dns
  verify_static_ip
  log "✅ Cluster verification complete."
}

main
