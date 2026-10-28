FROM python:3.10

RUN apt-get update && apt-get install -y --no-install-recommends cron && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY etl.py ./
RUN chmod +x etl.py
COPY tests ./tests

COPY crontab /etc/cron.d/etl
RUN chmod 0644 /etc/cron.d/etl