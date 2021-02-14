FROM python:3.7.9-slim-buster

ENV AIRFLOW_HOME="/usr/local/airflow"

ARG local_development=false
ENV LOCAL_DEVELOPMENT=$local_development

RUN set -ex \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        apt-utils \
        python3.7-dev \
        gcc \
        libcc1-0 \
        g++ \
        unixodbc \
        unixodbc-dev \
        curl \
        telnet \
    && pip install \
        apache-airflow==2.0.1 \
       #  --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.0.1/constraints-3.7.txt" \
         --use-deprecated=legacy-resolver \
    && pip install \
        'apache-airflow-providers-amazon' \
        'apache-airflow-providers-odbc' \
        'apache-airflow-providers-http' \
            --use-deprecated=legacy-resolver \
    && apt-get purge --auto-remove -yqq gcc python3.7-dev g++ libcc1-0 \
    && apt-get clean

# TODO: Develop a real initalization procedure
ARG AIRFLOW_EMAIL
ARG AIRFLOW_PASS
RUN airflow db init \
    && airflow users create -e ${AIRFLOW_EMAIL} -r Admin -f Ben -l Forleo -p ${AIRFLOW_PASS} -u airflow

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]

