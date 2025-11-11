# Imagen base oficial de AWS Lambda para Python 3.9
FROM public.ecr.aws/lambda/python:3.9

# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /var/task

# Copiar los archivos necesarios
COPY app.py ./
COPY requirements.txt ./

# Instalar las dependencias desde requirements.txt
RUN pip install -r requirements.txt

# Definir el handler de la función Lambda
# (archivo.nombre_variable_handler)
CMD ["app.mangum"]
