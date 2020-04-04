terraform {
  backend "s3" {
    key = "github-actions-tfstate"
  }
}

resource "random_string" "workspace_override" {
    length = 8
    special = false
}

module "github_action_testing" {
  source     = "github.com/whatsfordinner/github-actions-testing//infra"
  env_prefix = random_string.workspace_override.result
}