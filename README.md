# Github Actions Testing

Quick proof of concept using Github Actions to create temporary infrastructure using Terraform for testing pull requests.

# Overview

The proof of concept consists of a trivial, serverless application intended to run on AWS and a Terraform module that provisions the resources for the application.

## Application

The application is a Python function invoked via API Gateway that returns HTTP 200 and a 'Hello, world!' message.

## Terraform Module

The Terraform module creates the API Gateway, Lambda function and all the required supporting infrastructure. When applied, it uses a placeholder function that returns HTTP 501 and a 'placeholder function' error message.

## Github Workflows

There are two workflows defined:  

* 'Create Test Environment' - when a PR is opened or updated  
* 'Destroy Test Environment' - when a PR is closed

### Create Test Environment

This workflow is defined at `.github/workflows/create-test-env.yml`. It performs the following steps:  

1. Builds the application and runs unit tests  
2. Uses Terraform to create a temporary test environment using a portion of a hash of the PR branch as the Terraform workspace  
3. Packages the application and deploys it to the new test infrastructure  

### Destroy Test Environment

This workflow is defined at `.github/workflows/destroy-test-env.yml`. It destroys the temporary environment.
