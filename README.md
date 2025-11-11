# Punto2 FastAPI service

## Prerequisites
- Python 3.13+
- AWS credentials with permissions to read/write the designated S3 bucket
- Environment variables
  - `PUNTO2_S3_BUCKET`: bucket where the CSV will live
  - `PUNTO2_S3_KEY` (optional): key for the CSV object, defaults to `punto2/users.csv`
  - `AWS_REGION` (optional): region for the buckets' client

## Local usage
1. Install dependencies: `uv pip install -r requirements.txt` or `uv sync`
2. Run the API: `uvicorn punto2.server:app --reload`
3. Open Swagger UI at `http://127.0.0.1:8000/docs`
   - Use the `POST /users` form to create rows (nombre, edad, altura)
   - Use the `GET /users/count` try-it-out button to verify the CSV row count
4. Capture screenshots of the executed Swagger calls to satisfy the evidence requirement (curl is intentionally not used).

## Systemd service
The file `punto2/punto2.service` is a ready-to-customize unit. Copy it into `/etc/systemd/system/punto2.service` and update:
- `User`, `Group`, and `WorkingDirectory` to match the VM paths
- `Environment` values with the production bucket/key
- Optional `--port` if you expose something other than 8000

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now punto2.service
sudo systemctl status punto2.service
```

## Deployment outline (EC2)
1. Provision an EC2 instance with outbound internet access and the AWS IAM role/bucket access required.
2. Install Python 3.13, Git, and Uvicorn (or reuse uv toolchain).
3. Clone this repository, export the environment variables, and launch the API via the systemd service above.
4. Open the instance's security group to allow inbound TCP on the chosen port (default 8000) from the public internet.
5. Validate from a browser: `http://<public-ip>:8000/docs`, exercise both endpoints, and take screenshots of the executed requests for evidence.

> Screenshots cannot be generated in this environment, but the steps above describe exactly how to collect them locally and on the public instance.
