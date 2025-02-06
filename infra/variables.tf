variable "region" {
  default = "us-east-1"
}

variable "tags" {
  description = "Tags para a fila SQS"
  type        = map(string)
  default = {
    "Environment" = "Production"
    "Project"     = "Terraform-SQS"
  }
}