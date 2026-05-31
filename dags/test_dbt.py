from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from datetime import datetime,timedelta

default_args = {
    'owner': 'saipul',
    'depends_on_past': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='test_dbt',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['dbt', 'airflow', 'test','workshop'],
    default_args=default_args
)
def test_dbt():
    run_dbt = BashOperator(
        task_id='run_dbt',
        bash_command='cd /opt/airflow/include/dbt/sales_project/ && /opt/airflow/dbt_venv/bin/dbt --version && /opt/airflow/dbt_venv/bin/dbt debug'
    )

test_dbt()