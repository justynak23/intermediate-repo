# PLAN POLICY
#
# This example plan policy prevents you from creating weak passwords, and warns 
# you when passwords are meh.
#
# You can read more about plan policies here:
#
# https://docs.spacelift.io/concepts/policy/terraform-plan-policy
resource "spacelift_policy" "plan" {
  type = "PLAN"
  space_id = spacelift_space.intermediate-repo.id
  name = "Enforce password strength"
  body = file("${path.module}/policies/plan.rego")
}

# Plan policies only take effect when attached to the stack.
resource "spacelift_policy_attachment" "plan" {
  policy_id = spacelift_policy.plan.id
  stack_id  = spacelift_stack.managed.id
}

resource "spacelift_policy" "prnotification" {
  type = "NOTIFICATION"
  space_id = spacelift_space.intermediate-repo.id
  name = "PR feedback notification."
  body = file("${path.module}/policies/prnotification.rego")
}

resource "spacelift_policy" "tflint_checker" {
  type = "PLAN"
  space_id = spacelift_space.intermediate-repo.id
  name = "Tflint checker"
  labels = ["autoattach:tflint"]  
   body = file("${path.module}/policies/tflint.rego")
}
