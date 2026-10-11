terraform {
  cloud {
    organization = "kidora"

    workspaces {
      name = "kidora-preprod"
    }
  }
}   