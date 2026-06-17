# 06-lambda-apigateway – Opis zmian względem Lista 6

Folder bazuje na infrastrukturze z Lista 6 (VPC, ECS Fargate, ALB, RDS, S3, CloudWatch, Auto Scaling).
Dodano funkcję Lambda przetwarzającą wiadomości, REST API (API Gateway) oraz powiadomienia SNS o wykryciu liczby.

---

## Nowe pliki

### `lambda/handler.py` – kod funkcji Lambda

```python
lambda_handler(event, context)
```

**Logika:**
1. Parsuje `body` żądania HTTP (JSON), wyciąga pole `message`
2. Sprawdza regex `\d` – czy wiadomość zawiera cyfrę → `has_number`
3. Łączy się z PostgreSQL przez `pg8000` i tworzy tabelę `message_flags` (jeśli nie istnieje)
4. Zapisuje wiersz `(message, has_number, created_at)` do bazy
5. Jeśli `has_number = True` → wysyła powiadomienie do SNS
6. Zwraca JSON `{ message, has_number }` z kodem 200

**Sterownik bazy:** `pg8000` (pure Python – nie wymaga kompilacji natywnych bibliotek, działa na Lambda Linux).

---

## `main.tf` – nowe zasoby

### Security Group dla Lambdy

| Zasób | Opis |
|---|---|
| `aws_security_group.lambda_sg` | SG tylko z regułą egress (Lambda nie przyjmuje połączeń przychodzących) |

Modyfikacja `db_sg`: dodano drugi blok `ingress` zezwalający na port 5432 z `lambda_sg` – Lambda może łączyć się bezpośrednio z RDS.

---

### Pakowanie Lambdy

| Zasób | Opis |
|---|---|
| `null_resource.lambda_package` | Uruchamia PowerShell: `pip install pg8000 -t lambda/package/`, kopiuje `handler.py`. Trigger: hash pliku handler.py – przebudowuje ZIP tylko gdy kod się zmieni. |
| `data.archive_file.lambda_zip` | Tworzy ZIP z katalogu `lambda/package/` → `lambda/lambda.zip` |

---

### Funkcja Lambda

| Zasób | Opis |
|---|---|
| `aws_lambda_function.message_processor` | Runtime Python 3.12, timeout 30s, umieszczona w prywatnych podsieciach VPC (dostęp do RDS), SG: `lambda_sg` |
| `aws_lambda_permission.apigw` | Zezwala API Gateway na wywoływanie Lambdy (`lambda:InvokeFunction`) |

**Zmienne środowiskowe Lambdy:**

| Zmienna | Źródło |
|---|---|
| `DB_HOST` | `aws_db_instance.main.address` |
| `DB_NAME` | `var.db_name` |
| `DB_USER` | `var.db_username` |
| `DB_PASSWORD` | `var.db_password` |
| `SNS_TOPIC_ARN` | `aws_sns_topic.number_alerts.arn` |
| `APP_REGION` | `var.aws_region` (nie `AWS_REGION` – ta nazwa jest zarezerwowana przez Lambda runtime) |

---

### SNS – powiadomienia o liczbach

| Zasób | Opis |
|---|---|
| `aws_sns_topic.number_alerts` | Nowy temat SNS `lista7-app-number-alerts` – oddzielny od tematu alarmów CloudWatch |
| `aws_sns_topic_subscription.number_email` | Subskrypcja e-mail na `lambda_notification_email` – wymaga potwierdzenia kliknięciem linku |

---

### API Gateway REST API

| Zasób | Opis |
|---|---|
| `aws_api_gateway_rest_api.main` | REST API `lista7-app-api` |
| `aws_api_gateway_resource.messages` | Zasób `/messages` |
| `aws_api_gateway_method.post` | Metoda POST bez autoryzacji |
| `aws_api_gateway_integration.lambda` | Integracja typu `AWS_PROXY` – API GW przekazuje cały event do Lambdy bez modyfikacji |
| `aws_api_gateway_deployment.main` | Deploy API (lifecycle `create_before_destroy` – bezpieczna aktualizacja) |
| `aws_api_gateway_stage.prod` | Stage `prod` – generuje URL w formacie `https://<id>.execute-api.<region>.amazonaws.com/prod` |

---

## `variables.tf` – nowe zmienne

| Zmienna | Domyślna wartość | Opis |
|---|---|---|
| `lambda_notification_email` | `280655@student.pwr.edu.pl` | Adres e-mail dla powiadomień SNS o wykrytych liczbach |

---

## `outputs.tf` – nowe wyjścia

| Output | Opis |
|---|---|
| `api_gateway_url` | Pełny URL endpointu: `https://.../prod/messages` |
| `lambda_function_name` | Nazwa funkcji Lambda |
| `number_alerts_sns_arn` | ARN tematu SNS dla powiadomień o liczbach |

---

## Jak przetestować

```bash
# Wyślij wiadomość z liczbą (powinno zapisać flagę i wysłać e-mail SNS)
curl -X POST <api_gateway_url> \
  -H "Content-Type: application/json" \
  -d '{"message": "Mam 42 lata"}'

# Odpowiedź:
# {"message": "Mam 42 lata", "has_number": true}

# Wyślij wiadomość bez liczby (flaga false, brak e-maila)
curl -X POST <api_gateway_url> \
  -H "Content-Type: application/json" \
  -d '{"message": "Cześć jak się masz"}'

# Odpowiedź:
# {"message": "Cześć jak się masz", "has_number": false}
```

Wynik w bazie danych (tabela `message_flags` w bazie `chatdb`):

```sql
SELECT * FROM message_flags ORDER BY created_at DESC;
```
