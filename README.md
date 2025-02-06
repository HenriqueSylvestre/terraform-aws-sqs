# Projeto Terraform AWS SQS Queue

Este projeto cria duas filas SQS na AWS usando o Terraform. O objetivo é configurar uma fila principal, uma fila Dead Letter Queue (DLQ), e implementar uma política de redrive que move mensagens falhadas para a DLQ após um número específico de tentativas.

## Descrição

O projeto consiste em três recursos principais:

1. **Fila Principal (terraform_queue)**: Esta fila é configurada com parâmetros como atraso de mensagens, tamanho máximo das mensagens, tempo de retenção, e long polling. Ela também está associada com uma política de redrive que direciona mensagens falhadas para uma fila DLQ.

2. **Fila Dead Letter Queue (terraform_queue_deadletter)**: Esta fila é usada para armazenar mensagens que não puderam ser processadas com sucesso pela fila principal após um número específico de tentativas. A fila DLQ tem um tempo de retenção maior, permitindo o reprocessamento ou análise das mensagens falhadas.

3. **Política de Redrive (terraform_queue_redrive_allow_policy)**: Define uma política que permite que as mensagens falhadas sejam movidas da fila principal para a DLQ. Esta política ajuda a garantir que mensagens problemáticas não fiquem retidas na fila principal indefinidamente.

## Recursos Criados

### 1. Fila Principal (`terraform_queue`)

```hcl
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
```

- name: O nome da fila SQS. Neste caso, o nome é terraform-example-queue.
- delay_seconds: O atraso, em segundos, que será imposto antes que as mensagens sejam processadas. O valor é de 30 segundos.
- max_message_size: Define o tamanho máximo das mensagens, que é de 256 KB (262144 bytes).
- message_retention_seconds: O tempo de retenção das mensagens na fila. Aqui é configurado para 345600 segundos (4 dias).
- receive_wait_time_seconds: Define o tempo máximo de espera para long polling. O valor é de 10 segundos, o que significa que o SQS espera até 10 segundos para mensagens novas.
- redrive_policy: Configura a política de redrive, que move as mensagens falhadas para a fila DLQ após 4 falhas.
- fifo_queue: Indica que a fila não é FIFO (First-In-First-Out). O valor é false, ou seja, uma fila padrão.
- tags: Etiquetas personalizadas para os recursos, passadas através da variável var.tags

### 2. Fila Dead Letter Queue (terraform_queue_deadletter)

```hcl
resource "aws_sqs_queue" "terraform_queue_deadletter" {
name = "terraform-example-queue-dlq"
message_retention_seconds = 1209600 # 14 dias (padrão para DLQ)
max_message_size          = 262144
}
```

- name: O nome da fila DLQ. O nome configurado é terraform-example-queue-dlq.
- message_retention_seconds: O tempo de retenção das mensagens na DLQ. Este valor é de 1209600 segundos (14 dias), o tempo padrão para DLQs.
- max_message_size: O tamanho máximo das mensagens na DLQ, configurado para 256 KB.

### 3. Política de Redrive (terraform_queue_redrive_allow_policy)
```hcl
resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.terraform_queue_deadletter.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.terraform_queue.arn]
  })
}
```

- queue_url: URL da fila DLQ, que é usada como destino para mensagens falhadas. A fila terraform_queue_deadletter é configurada para receber as mensagens da fila principal.
- redrive_allow_policy: Define a política que permite o redrive das mensagens da fila principal para a DLQ. A opção redrivePermission = "byQueue" indica que a fila pode redirecionar mensagens para outra fila específica. O parâmetro sourceQueueArns especifica a fila de origem, ou seja, terraform_queue.

## Como Funciona o Redrive

- A política de redrive é utilizada para mover as mensagens falhadas da fila principal para a DLQ.
- Quando uma mensagem falha repetidamente (no caso, após 4 tentativas), ela é movida automaticamente para a fila DLQ.
- Isso ajuda a garantir que mensagens com falhas não permaneçam na fila principal, permitindo que sejam analisadas ou processadas novamente posteriormente.

## Considerações

- Fila não FIFO: O uso de filas não FIFO é útil quando a ordem das mensagens não é importante.
- Política de Redrive: Implementar uma DLQ com política de redrive é essencial para garantir a confiabilidade do sistema, especialmente quando as mensagens não podem ser processadas corretamente.

## Como Usar

1.Pré-requisitos:
- Tenha o Terraform instalado e configurado com suas credenciais AWS.
- Tenha permissão para criar recursos na AWS SQS.
- Aplicar a configuração:

2.Inicialize o Terraform: terraform init
- Planeje a aplicação das configurações: terraform plan
- Aplique a configuração: terraform apply

3.Gerenciar recursos: Após aplicar, o Terraform criará as filas SQS e as políticas associadas.

## Conclusão

Esse projeto é uma configuração simples, mas robusta, de filas SQS na AWS, incluindo uma fila principal, uma DLQ, e uma política de redrive para lidar com falhas na entrega de mensagens. Isso ajuda a garantir a confiabilidade e a integridade das mensagens processadas.

