# --- YumDeal Infrastructure Variables ---
# Project: YumDeal v1.0.0 [cite: 58]
# Purpose: Define schema for variables used in main.tf

variable "azure_subscription_id" {
  description = "The Azure subscription ID where resources are deployed"
  type        = string
}

variable "vm_admin_username" {
  description = "Default admin username for the Ubuntu VM"
  type        = string
  default     = "azureuser-yumdeal"
}

variable "ssh_public_key" {
  description = "Public SSH key for VM authentication"
  type        = string
  sensitive   = true # Prevents the key from being logged in plain text
}

variable "admin_ip_address" {
  description = "The public IP authorized to access SSH and Airflow management ports"
  type        = string
}

variable "common_tags" {
  description = "Common metadata tags applied to all YumDeal resources"
  type        = map(string)
  default = {
    project     = "yumdeal"
    environment = "production"
    owner       = "yumdeal@outlook.com"
    cost-center = "personal"
    managed-by  = "terraform"
  }
}

# --- Snowflake Backend Variables ---
# Required for the dbt ELT pipeline and SCD Type 2 snapshots [cite: 81, 91]

variable "snowflake_account" {
  description = "Snowflake account identifier"
  type        = string
  sensitive   = true
}

variable "snowflake_user" {
  description = "Snowflake service user for ETL"
  type        = string
  sensitive   = true
}

variable "snowflake_password" {
  description = "Snowflake user password"
  type        = string
  sensitive   = true
}