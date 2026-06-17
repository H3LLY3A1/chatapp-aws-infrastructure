# Design: 06-lambda-apigateway (Lista 7)

## Cel

Rozszerzenie infrastruktury z Listy 6 o funkcję Lambda przetwarzającą wiadomości czatu,
REST API (API Gateway) jako punkt końcowy, oraz powiadomienia SNS o wykryciu liczby.

## Architektura

```
POST /messages (API Gateway)
        ↓
  Lambda (Python 3.12, w VPC)
    ↙               ↘
RDS PostgreSQL     SNS topic
(tabela             (e-mail gdy
message_flags)      has_number=true)
```

## Nowe zasoby

- `aws_security_group.lambda_sg` — SG Lambdy, egress-only
- `null_resource.lambda_package` + `archive_file.lambda_zip` — pakowanie handler + pg8000
- `aws_lambda_function.message_processor` — Python 3.12, timeout 30s, w VPC (private subnets)
- `aws_lambda_permission.apigw` — pozwala API GW wywoływać Lambdę
- `aws_api_gateway_rest_api.main` + resource `/messages` + metoda POST + integracja AWS_PROXY
- `aws_api_gateway_deployment` + `aws_api_gateway_stage.prod`
- `aws_sns_topic.number_alerts` + `aws_sns_topic_subscription.number_email`

## Modyfikacje istniejących zasobów

- `aws_security_group.db_sg`: dodanie ingress 5432 od `lambda_sg`
- `var.project_name`: zmiana na `lista7-app`

## Lambda — logika

1. Parse body JSON → pole `message`
2. `re.search(r'\d', message)` → `has_number`
3. `CREATE TABLE IF NOT EXISTS message_flags` (idempotent)
4. `INSERT INTO message_flags (message_content, has_number, created_at)`
5. Jeśli `has_number` → `sns.publish()`
6. Return 200 `{ message, has_number }`

## Sterownik bazy danych

`pg8000` — pure Python, nie wymaga kompilacji natywnych bibliotek, działa na Lambda Linux.

## Zmienne nowe

- `lambda_notification_email` — adres dla SNS number_alerts
- `cpu_high_threshold`, `cpu_scale_target`, `min/max_task_count` — bez zmian

## Outputs nowe

- `api_gateway_url` — pełny URL endpointu POST /messages
- `lambda_function_name`
- `number_alerts_sns_arn`
