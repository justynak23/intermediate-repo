terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
}
