FROM apache/airflow:3.2.2


ENV PIP_USER=false

RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-bigquery==1.11.0 && deactivate

ENV PIP_USER=true