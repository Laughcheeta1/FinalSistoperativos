#!/bin/bash
# Script para construir y subir una imagen Docker a AWS ECR (compatible con Lambda)
# Uso: ./deploy_to_ecr.sh <aws_account_id> <region> <repo_name>

# --------- Variables ---------
AWS_ACCOUNT_ID=$1
REGION=$2
REPO_NAME=$3
IMAGE_TAG="latest"

# --------- Validaciones ---------
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$REGION" ] || [ -z "$REPO_NAME" ]; then
  echo "Uso: $0 <aws_account_id> <region> <repo_name>"
  exit 1
fi

ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}"

# --------- Construir imagen ---------
echo "🛠️ Construyendo imagen Docker compatible con AWS Lambda..."
# Desactivamos BuildKit para que el manifest quede en formato Docker schema2 (aceptado por Lambda)
DOCKER_BUILDKIT=0 docker build \
  --no-cache \
  --platform linux/amd64 \
  -t ${REPO_NAME}:${IMAGE_TAG} .

# --------- Etiquetar imagen ---------
echo "🏷️ Etiquetando imagen como ${ECR_URI}:${IMAGE_TAG}..."
docker tag ${REPO_NAME}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

# --------- Login a ECR ---------
echo "🔐 Iniciando sesión en Amazon ECR..."
aws ecr get-login-password --region ${REGION} | \
docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# --------- Crear repositorio si no existe ---------
echo "🗂️ Verificando si el repositorio existe..."
aws ecr describe-repositories --repository-names ${REPO_NAME} --region ${REGION} >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "📦 Repositorio no encontrado, creando uno nuevo..."
  aws ecr create-repository --repository-name ${REPO_NAME} --region ${REGION}
fi

# --------- Subir imagen ---------
echo "⬆️ Subiendo imagen a ECR..."
docker push ${ECR_URI}:${IMAGE_TAG}

echo "✅ Imagen subida exitosamente a: ${ECR_URI}:${IMAGE_TAG}"
