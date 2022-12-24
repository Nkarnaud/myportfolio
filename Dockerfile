FROM python:3.9-bullseye AS builder

RUN useradd -ms /bin/bash pythonrunner

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    python3-dev \
    libpq-dev \
    wget \
    iputils-ping \
    vim

USER pythonrunner

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -U --no-cache-dir uwsgi pip setuptools wheel
RUN pip3 install --no-cache-dir --user -r /tmp/requirements.txt


FROM python:3.9-slim-bullseye AS prod-container


RUN useradd -ms /bin/bash pythonrunner

WORKDIR /app
RUN chown -R pythonrunner:pythonrunner /app

RUN apt-get update && \
    apt-get install -y \
    libpq-dev \
    libxml2

COPY --chown=pythonrunner:pythonrunner --from=builder /home/pythonrunner/.local /usr/local
COPY --chown=pythonrunner:pythonrunner mywebsite /app/
COPY --chown=pythonrunner:pythonrunner uwsgi.ini /app/uwsgi.ini

USER pythonrunner

EXPOSE 8000

CMD ["uwsgi", "--ini", "/app/uwsgi.ini"]
