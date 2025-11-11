import csv
import io
import os
from typing import List

import boto3
from botocore.exceptions import ClientError
from fastapi import FastAPI, HTTPException

from punto2.model import User


CSV_FIELDS = ["nombre", "edad", "altura"]

app = FastAPI(title="Punto2 API", version="1.0.0")


def _get_s3_client():
    region_name = "us-east-2"
    return boto3.client("s3", region_name=region_name)


def _read_rows(bucket: str) -> List[dict]:
    print(f"This is the bucket: {bucket}")
    try:
        response = _get_s3_client().get_object(Bucket=bucket, Key="punto2/users.csv")
    except ClientError:
        # The files does not exist yet. Create it
        return []
        

    body = response["Body"].read().decode("utf-8")
    if not body.strip():
        return []

    reader = csv.DictReader(io.StringIO(body))
    return list(reader)


def _write_rows(bucket: str, rows: List[dict]) -> None:
    buffer = io.StringIO()
    writer = csv.DictWriter(buffer, fieldnames=CSV_FIELDS)
    writer.writeheader()
    writer.writerows(rows)

    try:
        _get_s3_client().put_object(
            Bucket=bucket,
            Key="punto2/users.csv",
            Body=buffer.getvalue().encode("utf-8"),
            ContentType="text/csv",
        )
    except ClientError as exc:
        error_code = exc.response["Error"].get("Code", "")
        raise HTTPException(status_code=502, detail=f"Error writing CSV to S3: {error_code}") from exc


@app.post("/users", status_code=201)
def create_user(user: User):
    bucket = "final-sist-operativos"
    rows = _read_rows(bucket)
    rows.append(user.model_dump())

    _write_rows(bucket, rows)
    return {"row_count": len(rows)}


@app.get("/users/count")
def count_users():
    bucket = "final-sist-operativos"
    rows = _read_rows(bucket)
    return {"row_count": len(rows)}
