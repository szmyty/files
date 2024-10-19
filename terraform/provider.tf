# terraform/provider.tf
provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("<PATH_TO_YOUR_SERVICE_ACCOUNT_KEY>.json")
}
