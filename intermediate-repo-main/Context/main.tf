data "spacelift_space_by_path" "intermediate-repo" {
  space_path = "root/intermediate-repo"
}

output "space_id" {
  value = data.spacelift_space_by_path.intermediate-repo.id
}

resource "spacelift_context" "drift-detection-test" {
  description = "Context to test drift detection"
  space_id          = data.spacelift_space_by_path.intermediate-repo.id
  name        = "drift detection test"
}
