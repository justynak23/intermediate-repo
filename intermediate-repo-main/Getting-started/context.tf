# This resource creates context which has the hooks needed to download and run TFLINT.
# We also added the label autoattach:tflint so this context will attach to any stack or module with the label tflint.
# You can read about using hooks to integrate with tools here
#
# https://spacelift.io/blog/integrating-security-tools-with-spacelift


resource "spacelift_context" "tflint" {
  description = "Context to run tflint on stacks"
  name        = "TFlint context"
  space_id = spacelift_space.intermediate-repo.id
  before_init = [
    "wget https://github.com/terraform-linters/tflint/releases/download/v0.50.1/tflint_linux_amd64.zip",
    "unzip tflint_linux_amd64.zip",
    "chmod +x tflint",
    "./tflint --format=json > tflint.custom.spacelift.json || true"
  ]
  labels = ["autoattach:tflint"]
}

