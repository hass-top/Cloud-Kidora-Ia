  terraform {
    required_version = ">= 1.6"

    required_providers {

      vultr = {
        source  = "vultr/vultr"
        version = "~> 2.21"
      }
    }
  }

  provider "vultr" {
    api_key = var.vultr_api_key
    
    # Retry configuration for transient API errors
    retry_max_attempts = 5
    retry_min_jitter   = 1
    retry_max_jitter   = 30
  }


