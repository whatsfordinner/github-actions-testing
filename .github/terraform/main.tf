terraform {
  backend "s3" {
    workspace_key_prefix = "github-actions-testing"
    key                  = "tfstate"
  }
}

module "github_action_testing" {
  source = "github.com/whatsfordinner/github-actions-testing//infra"
}