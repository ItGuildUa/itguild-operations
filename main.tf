terraform {
  required_version = ">= 1.0.5"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.19.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
  }
}

provider "github" {
  token = var.secrets.github_token
  owner = var.github.organization
}
