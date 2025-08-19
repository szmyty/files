#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID=$(gcloud config get-value project)
ZONE="us-east1-b"
CLUSTER_NAME="dnd-wiki-cluster"
NAMESPACE="wikijs"
NUM_NODES=2
MACHINE_TYPE="e2-medium"
DISK_TYPE="pd-balanced"
DISK_SIZE=100
RELEASE_CHANNEL="regular"
ADDONS="HttpLoadBalancing,GcePersistentDiskCsiDriver"
ENABLE_BACKUP=true
LOG_FILE="create_cluster.log"

# Weekly window: Saturdays 12:00 AM UTC → Mondays 12:00 AM UTC (48 hours)
MAINTENANCE_RRULE="FREQ=WEEKLY;BYDAY=MO,TU,WE,TH"
MAINTENANCE_START="2025-05-16T03:00:00Z"
MAINTENANCE_END="2025-05-16T11:00:00Z"

# Black Friday 2026 maintenance exclusion window
BLACK_FRIDAY_NAME="black-friday"
BLACK_FRIDAY_START="2026-11-27T00:00:00-05:00"
BLACK_FRIDAY_END="2026-11-30T23:59:59-08:00"
BLACK_FRIDAY_SCOPE="no_upgrades"

REQUIRED_APIS=(
  container.googleapis.com
  compute.googleapis.com
  certificatemanager.googleapis.com
  dns.googleapis.com
  cloudresourcemanager.googleapis.com
  serviceusage.googleapis.com
)

REQUIRED_TOOLS=(
    gcloud
    kubectl
    jq
    helm
)

trap 'echo "❌ Cluster creation failed. Check $LOG_FILE for details." >&2' ERR

log() {
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') 🔹 $1" | tee -a "$LOG_FILE"
}

check_prereqs() {
    log "🔍 Checking for required tools..."
  local missing=false

  for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
      log "❌ Required tool '$tool' is not installed or not in PATH."
      missing=true
    fi
  done

  if [[ "$missing" == true ]]; then
    log "🚫 One or more prerequisites are missing. Please install them before running this script."
    exit 1
  fi

    log "✅ All required tools are installed."
}

if [[ "$ENABLE_BACKUP" == true ]]; then
  REQUIRED_APIS+=("gkebackup.googleapis.com")
  ADDONS="$ADDONS,BackupRestore"
fi

enable_apis() {
    log "🔍 Checking and enabling required APIs..."
  for api in "${REQUIRED_APIS[@]}"; do
    if ! gcloud services list --enabled --format="value(config.name)" | grep -q "$api"; then
      log "🔧 Enabling API: $api"
      gcloud services enable "$api" | tee -a "$LOG_FILE"
    else
      log "✅ API already enabled: $api"
    fi
  done
}

describe_cluster() {
  local format=json
  gcloud container clusters describe "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --format="$format" 2>/dev/null
}

describe_cluster_field() {
  local format="$1"
  gcloud container clusters describe "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --format="value($format)"
}

get_cluster_name() {
  describe_cluster_field 'name'
}

get_cluster_status() {
  describe_cluster_field 'status'
}

get_cluster_location() {
  describe_cluster_field 'location'
}

get_cluster_node_count() {
  describe_cluster_field 'currentNodeCount'
}

get_maintenance_rrule() {
  describe_cluster_field 'maintenancePolicy.window.recurringWindow.recurrence'
}

get_maintenance_start() {
  describe_cluster_field 'maintenancePolicy.window.recurringWindow.window.startTime'
}

get_maintenance_end() {
  describe_cluster_field 'maintenancePolicy.window.recurringWindow.window.endTime'
}

get_maintenance_exclusions() {
  gcloud container clusters describe "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --format="json(maintenancePolicy.window.maintenanceExclusions)" 2>/dev/null
}

has_exclusion() {
  local name="$1"
  get_maintenance_exclusions | jq -e --arg name "$name" \
    '.maintenancePolicy.window.maintenanceExclusions | has($name)' >/dev/null
}

print_cluster_info() {
    local cluster_info
    cluster_info=$(describe_cluster)

    if [[ -z "$cluster_info" ]]; then
        log "❌ Failed to retrieve cluster information."
        return 1
    fi

    log "🔍 Cluster Information:"
    log "Name: $(get_cluster_name)"
    log "Status: $(get_cluster_status)"
    log "Location: $(get_cluster_location)"
    log "Node Count: $(get_cluster_node_count)"
    log "Maintenance RRULE: $(get_maintenance_rrule)"
    log "Maintenance Start: $(get_maintenance_start)"
    log "Maintenance End: $(get_maintenance_end)"
}

create_cluster() {
  if gcloud container clusters describe "$CLUSTER_NAME" --zone "$ZONE" >/dev/null 2>&1; then
    log "✅ Cluster $CLUSTER_NAME already exists. Skipping creation."
  else
    log "🚀 Creating GKE cluster: $CLUSTER_NAME"
    gcloud container clusters create "$CLUSTER_NAME" \
      --project "$PROJECT_ID" \
      --zone "$ZONE" \
      --machine-type "$MACHINE_TYPE" \
      --disk-type "$DISK_TYPE" \
      --disk-size "$DISK_SIZE" \
      --num-nodes "$NUM_NODES" \
      --scopes="https://www.googleapis.com/auth/cloud-platform" \
      --enable-ip-alias \
      --addons="$ADDONS" \
      --release-channel="$RELEASE_CHANNEL" \
      --enable-autorepair \
      --enable-autoupgrade \
      --no-enable-basic-auth \
      --no-issue-client-certificate \
      --metadata disable-legacy-endpoints=true \
      --enable-shielded-nodes \
      --quiet | tee -a "$LOG_FILE"
    log "✅ Cluster $CLUSTER_NAME created."
    print_cluster_info
  fi
}

configure_maintenance_window() {
    log "🔍 Checking existing maintenance window..."
    CURRENT_RRULE=$(get_maintenance_rrule)
    CURRENT_START=$(get_maintenance_start)
    CURRENT_END=$(get_maintenance_end)

    log "🔧 Configuring maintenance window..."

    if [[ "$CURRENT_RRULE" == "$MAINTENANCE_RRULE" && "$CURRENT_START" == "$MAINTENANCE_START" && "$CURRENT_END" == "$MAINTENANCE_END" ]]; then
        log "✅ Maintenance window already set correctly. Skipping."
    else
        log "🛠️ Setting weekly maintenance window: $MAINTENANCE_RRULE, $MAINTENANCE_START → $MAINTENANCE_END"
        gcloud container clusters update "$CLUSTER_NAME" \
            --zone "$ZONE" \
            --maintenance-window-start "$MAINTENANCE_START" \
            --maintenance-window-end "$MAINTENANCE_END" \
            --maintenance-window-recurrence "$MAINTENANCE_RRULE" \
            --quiet | tee -a "$LOG_FILE"
    fi

    log "🔍 Checking if maintenance exclusion '$BLACK_FRIDAY_NAME' exists..."
    if has_exclusion "$BLACK_FRIDAY_NAME"; then
        log "✅ Maintenance exclusion '$BLACK_FRIDAY_NAME' already set. Skipping."
    else
        log "🛑 Adding maintenance exclusion window: $BLACK_FRIDAY_NAME ($BLACK_FRIDAY_START → $BLACK_FRIDAY_END)"
        gcloud container clusters update "$CLUSTER_NAME" \
            --zone "$ZONE" \
            --add-maintenance-exclusion-name "$BLACK_FRIDAY_NAME" \
            --add-maintenance-exclusion-start "$BLACK_FRIDAY_START" \
            --add-maintenance-exclusion-end "$BLACK_FRIDAY_END" \
            --add-maintenance-exclusion-scope "$BLACK_FRIDAY_SCOPE" \
            --quiet | tee -a "$LOG_FILE"
    fi

    log "✅ Maintenance window and exclusions configured."
}

configure_kubectl() {
  log "🔐 Checking kubectl credentials..."

  if kubectl config get-contexts --no-headers | grep -q "$CLUSTER_NAME"; then
    log "✅ Credentials already configured for $CLUSTER_NAME. Skipping."
  else
    log "🔐 Fetching credentials..."
    gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE" --project "$PROJECT_ID"
  fi

  log "📂 Creating namespace: $NAMESPACE (if not exists)"
  if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    kubectl create namespace "$NAMESPACE"
    log "✅ Namespace $NAMESPACE created."
  else
    log "✅ Namespace $NAMESPACE already exists."
  fi
}

main() {
  log "🔧 Starting cluster setup in project: $PROJECT_ID"
  check_prereqs
  enable_apis
  create_cluster
  configure_maintenance_window
  configure_kubectl
  log "✅ GKE cluster setup complete. Namespace: $NAMESPACE"
}

main
