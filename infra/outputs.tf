output "queue_url" {
  value = aws_sqs_queue.terraform_queue.url
  description = "Url from aws sqs queue"
}

output "queue_dlq_url" {
  value = aws_sqs_queue.terraform_queue_deadletter.url
  description = "Url from aws sqs queue dlq"
}

output "queue_arn" {
  value = aws_sqs_queue.terraform_queue.arn
}

output "queue_dlq_arn" {
  value = aws_sqs_queue.terraform_queue_deadletter.arn
}

output "queue_name" {
  value = aws_sqs_queue.terraform_queue.name
}

output "queue_dlq_name" {
  value = aws_sqs_queue.terraform_queue_deadletter.name
}