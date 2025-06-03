variable "APP_DB_URL" {
  description = "The database URL for the application"
  type        = string
}

resource "null_resource" "app" {
  provisioner "local-exec" {
    command = "echo ${var.APP_DB_URL} > app_db_url.txt"
  }
}
