FROM python:3.9-slim
WORKDIR /app
ADD . /app

RUN apt-get update && apt-get install -y apache2-utils

CMD ["sh", "-c", "python make-data.py && bash generate-votes.sh"]


