# --- YumDeal Infrastructure Outputs ---
# Project: YumDeal v1.0.0
# Purpose: Display critical connection endpoints after deployment

output "vm_public_ip" {
  description = "The public IP address of the YumDeal production VM."
  value       = azurerm_public_ip.res-10.ip_address
}

output "ssh_connection_string" {
  description = "Convenience command to SSH into the VM."
  value       = "ssh ${var.vm_admin_username}@${azurerm_public_ip.res-10.ip_address}"
}

output "fastapi_ingest_url" {
  description = "The endpoint for the extension to POST deal data."
  value       = "http://${azurerm_public_ip.res-10.ip_address}:8000/api/v1/ingest"
}

output "airflow_dashboard_url" {
  description = "The URL for the Airflow management UI."
  value       = "http://${azurerm_public_ip.res-10.ip_address}:8080"
}

output "storage_account_name" {
  description = "The name of the Azure Storage Account used for the raw data lake."
  value       = azurerm_storage_account.res-13.name
}

output "resource_group_name" {
  description = "The Azure resource group containing all YumDeal services."
  value       = azurerm_resource_group.res-0.name
}