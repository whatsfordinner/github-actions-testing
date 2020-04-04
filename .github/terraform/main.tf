terraform {
  backend "s3" {
    key = "github-actions-tfstate"
  }
}

module "github_action_testing" {
  source = "github.com/whatsfordinner/github-actions-testing//infra"
}