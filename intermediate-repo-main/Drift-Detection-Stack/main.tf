data "spacelift_space_by_path" "intermediate-repo" {
  space_path = "root/intermediate-repo"
}

output "space_id" {
  value = data.spacelift_space_by_path.intermediate-repo.id
}

resource "spacelift_stack" "drift_detection_example" {
  space_id          = data.spacelift_space_by_path.intermediate-repo.id
  description       = "Provisions a stack with drift detection"
  name              = "Stack with drift detection enabled"
  administrative = true
  repository        = "intermediate-repo"
  branch            = "main"
  project_root      = "Context"
  worker_pool_id    = var.worker_pool_id
}

resource "spacelift_stack_destructor" "drift_detection_example" {
  stack_id = spacelift_stack.drift_detection_example.id
}

variable "worker_pool_id" {
  description = "ID of the worker pool to use"
  type        = string
}

resource "spacelift_drift_detection" "core_infra_production_drift_detection" {
  reconcile = true
  stack_id  = spacelift_stack.drift_detection_example.id
  schedule  = var.drift_detection_schedule
}

variable "drift_detection_schedule" {
  description = "Schedule for drift detection in cron format"
  type        = list(string)
  default     = ["*/15 * * * *"]  # Default to every 15 minutes
}
