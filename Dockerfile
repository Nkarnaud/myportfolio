FROM python:3.10.5-alpine3.15 AS builder

RUN addgroup -S pythonrunner && adduser -u 1000 -S -g pythonrunner pythonrunner

WORKDIR /app

RUN apk add --update \
    python3 \
    python3-dev \
    build-base \
    wget \
    vim \
    gcc \
    g++ \
    make \
    libffi-dev \
    linux-headers \
    pcre-dev \
    zeromq-dev \
    libxml2-dev \
    libxslt-dev \
    py-cffi \
    openssl \
    zlib-dev \
    libmemcached \
    postgresql-dev \
    shadow

USER pythonrunner

COPY requirements.txt /tmp/requirements.txt

RUN pip3 install -U --no-cache-dir uwsgi pip setuptools wheel
RUN pip3 install --no-cache-dir --user -r /tmp/requirements.txt


FROM python:3.10.5-alpine3.15 AS prod-container

RUN addgroup -S pythonrunner && adduser -u 1000 -S -g pythonrunner pythonrunner

WORKDIR /app
RUN chown -R pythonrunner:pythonrunner /app

RUN apk --no-cache add \
    libpq \
    libxml2 \
    libxslt \
    pcre

COPY --chown=pythonrunner:pythonrunner --from=builder /home/pythonrunner/.local /usr/local
COPY --chown=pythonrunner:pythonrunner privybox /app/
COPY --chown=pythonrunner:pythonrunner .iac/uwsgi.ini /app

USER pythonrunner

EXPOSE 8080

CMD ["uwsgi", "--ini", "/app/uwsgi.ini"]


FROM builder AS dev-container

USER root

COPY --from=pyroscope/pyroscope:latest /usr/bin/pyroscope /usr/bin/pyroscope

ENV PYROSCOPE_APPLICATION_NAME=cloaked.backend
ENV PYROSCOPE_SERVER_ADDRESS=http://pyroscope:4040/
ENV PYROSCOPE_LOG_LEVEL=debug

COPY requirements.txt /tmp/requirements.txt
COPY requirements-dev.txt /tmp/requirements-dev.txt
RUN pip install --no-cache-dir -r /tmp/requirements-dev.txt
RUN cp -r /home/pythonrunner/.local/* /usr/local

WORKDIR /app/privybox
USER pythonrunner

CMD ["ash"]
