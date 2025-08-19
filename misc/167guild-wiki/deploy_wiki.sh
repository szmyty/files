#!/usr/bin/env bash
set -euo pipefail

RELEASE_NAME="dnd-wiki"
NAMESPACE="wikijs"
DOMAIN="wiki.167guild.io"
STATIC_IP_NAME="wikijs-ip"
VALUES_FILE="values.yaml"
CERT_FILE="wikijs-cert.yaml"
INGRESS_FILE="wikijs-ingress.yaml"
LOG_FILE="deploy_wikijs.log"

trap 'echo "❌ Deployment failed. See $LOG_FILE for details." >&2' ERR

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') 🔹 $1" | tee -a "$LOG_FILE"
}

create_values_yaml() {
  if [[ ! -f "$VALUES_FILE" ]]; then
    log "📄 Creating values.yaml"
    cat <<EOF > "$VALUES_FILE"
postgresql:
  postgresqlPassword: mysecurepassword
  postgresqlDatabase: wiki

resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
EOF
  else
    log "✅ $VALUES_FILE already exists. Skipping."
  fi
}

create_cert_yaml() {
  if [[ ! -f "$CERT_FILE" ]]; then
    log "🔐 Creating TLS certificate manifest"
    cat <<EOF > "$CERT_FILE"
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: wikijs-cert
  namespace: $NAMESPACE
spec:
  domains:
    - $DOMAIN
EOF
  else
    log "✅ $CERT_FILE already exists. Skipping."
  fi
}

create_ingress_yaml() {
  if [[ ! -f "$INGRESS_FILE" ]]; then
    log "🌐 Creating Ingress manifest"
    cat <<EOF > "$INGRESS_FILE"
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wikijs-ingress
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/ingress.global-static-ip-name: $STATIC_IP_NAME
    networking.gke.io/managed-certificates: wikijs-cert
spec:
  ingressClassName: gce
  rules:
    - host: $DOMAIN
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: $RELEASE_NAME
                port:
                  number: 3000
EOF
  else
    log "✅ $INGRESS_FILE already exists. Skipping."
  fi
}

deploy_helm_chart() {
  log "📦 Installing or upgrading Wiki.js with Helm"
  helm repo add requarks https://charts.js.wiki || true
  helm repo update
  helm upgrade --install "$RELEASE_NAME" requarks/wiki \
    --namespace "$NAMESPACE" \
    --create-namespace \
    -f "$VALUES_FILE"
}

apply_manifests() {
  log "🔐 Applying TLS certificate"
  kubectl apply -f "$CERT_FILE"

  log "🌐 Applying Ingress"
  kubectl apply -f "$INGRESS_FILE"
}

main() {
  log "🚀 Starting Wiki.js deployment for domain $DOMAIN"
  create_values_yaml
  create_cert_yaml
  create_ingress_yaml
  deploy_helm_chart
  apply_manifests
  log "✅ Wiki.js deployed. Monitor with:"
  echo "   kubectl get ingress -n $NAMESPACE"
  echo "   kubectl describe managedcertificate wikijs-cert -n $NAMESPACE"
}

main
