import json
import os
import re
import boto3
import pg8000.dbapi


def _get_conn():
    return pg8000.dbapi.connect(
        host=os.environ["DB_HOST"],
        database=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        port=5432,
    )


def _ensure_table(conn):
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS message_flags (
            id         SERIAL    PRIMARY KEY,
            message    TEXT      NOT NULL,
            has_number BOOLEAN   NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT NOW()
        )
    """)
    conn.commit()
    cur.close()


def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    message = body.get("message", "")

    has_number = bool(re.search(r"\d", message))

    conn = _get_conn()
    try:
        _ensure_table(conn)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO message_flags (message, has_number) VALUES (%s, %s)",
            (message, has_number),
        )
        conn.commit()
        cur.close()
    finally:
        conn.close()

    if has_number:
        sns = boto3.client("sns", region_name=os.environ["APP_REGION"])
        sns.publish(
            TopicArn=os.environ["SNS_TOPIC_ARN"],
            Subject="Wykryto liczbę w wiadomości",
            Message=(
                f'Wiadomość: "{message}"\n'
                "Flaga has_number=True została zapisana w bazie danych."
            ),
        )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
        },
        "body": json.dumps(
            {"message": message, "has_number": has_number}, ensure_ascii=False
        ),
    }
