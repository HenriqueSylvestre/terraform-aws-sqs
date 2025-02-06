resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue"
  delay_seconds             = 30
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
    maxReceiveCount     = 4
  })
  fifo_queue = false

  tags = var.tags
}

resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name = "terraform-example-queue-dlq"
  message_retention_seconds = 1209600 # 14 dias (padrão para DLQ)
  max_message_size          = 262144
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.terraform_queue_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.terraform_queue.arn]
  })
}