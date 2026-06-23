import os
import re
import boto3 # aws sdk do sns
import pg8000.dbapi #sterownik do PostgreSQL kompatybilny z AWS RDS Proxy 


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
        CREATE TABLE IF NOT EXISTS message (
            id         SERIAL  PRIMARY KEY,
            message    TEXT    NOT NULL,
            has_number BOOLEAN NOT NULL
        )
    """)
    conn.commit()
    cur.close()


def lambda_handler(event, context):
    message = event.get("message", "")

    has_number = bool(re.search(r"\d", message))

    conn = _get_conn()
    try:
        _ensure_table(conn)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO message (message, has_number) VALUES (%s, %s)",
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
            Subject="Number",
            Message=f"The message '{message}' contains a number.",
        )

    return {"message": message, "has_number": has_number}
