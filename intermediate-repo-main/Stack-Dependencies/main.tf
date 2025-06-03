data "spacelift_space_by_path" "intermediate-repo" {
  space_path = "root/intermediate-repo"
}

output "space_id" {
  value = data.spacelift_space_by_path.intermediate-repo.id
}
resource "spacelift_stack" "infra" {
  branch       = "main"
  name         = "Infrastructure stack"
  space_id          = data.spacelift_space_by_path.intermediate-repo.id
  repository   = "intermediate-repo"
  project_root = "Stack-Dependencies/Infra"
}

resource "spacelift_stack" "app" {
  branch       = "main"
  name         = "Application stack"
  space_id          = data.spacelift_space_by_path.intermediate-repo.id
  repository   = "intermediate-repo"
  project_root = "Stack-Dependencies/App"
}

resource "spacelift_stack_dependency" "dependency" {
  stack_id            = spacelift_stack.app.id
  depends_on_stack_id = spacelift_stack.infra.id
}

resource "spacelift_stack_dependency_reference" "reference" {
  stack_dependency_id = spacelift_stack_dependency.dependency.id
  output_name         = "DB_CONNECTION_STRING"
  input_name          = "TF_VAR_APP_DB_URL"
}
