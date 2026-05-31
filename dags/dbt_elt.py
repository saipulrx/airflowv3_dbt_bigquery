from datetime import datetime
from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from airflow import Asset

# ==========================================
# KONFIGURASI
# ==========================================
# 1. Deklarasi Asset (String ini HARUS sama persis dengan outlets di DAG Producer)
CLEAN_SALES_ASSET = Asset("bq://sales-prod.raw.sales")

# 2. Path menuju folder proyek dbt Anda di dalam container Airflow
DBT_PROJECT_DIR = "/opt/airflow/include/dbt/sales_project"

@dag(
    dag_id="lab4_consumer_dbt_bash",
    # KUNCI UTAMA: Menjadwalkan DAG ini berdasarkan Asset, bukan waktu
    schedule=[CLEAN_SALES_ASSET], 
    start_date=datetime(2026, 5, 30),
    catchup=False,
    tags=["workshop", "consumer", "dbt"]
)
def dbt_consumer_pipeline():

    # ------------------------------------------
    # TASK: Eksekusi dbt menggunakan BashOperator
    # ------------------------------------------
    run_seed_dbt = BashOperator(
        task_id="execute_dbt_seed",
        # Perintah bash multiline untuk pindah folder lalu mengeksekusi dbt
        bash_command=f"""
            echo ">> Memulai proses Consumer..."
            echo ">> Berpindah ke folder proyek dbt: {DBT_PROJECT_DIR}"
            cd {DBT_PROJECT_DIR}
            
            echo ">> Mengecek versi dan koneksi dbt..."
            /opt/airflow/dbt_venv/bin/dbt debug
            
            echo ">> Mengeksekusi dbt seed..."
            # Command dbt seed akan menjalankan semua seed terlebih dahulu
            /opt/airflow/dbt_venv/bin/dbt seed
            
            echo ">> Proses seed selesai dengan sukses!"
        """
    )

    run_model_dbt = BashOperator(
        task_id="execute_dbt_models",
        # Perintah bash multiline untuk pindah folder lalu mengeksekusi dbt
        bash_command=f"""
            echo ">> Memulai proses Consumer..."
            echo ">> Berpindah ke folder proyek dbt: {DBT_PROJECT_DIR}"
            cd {DBT_PROJECT_DIR}
            
            echo ">> Mengeksekusi transformasi dbt model (dbt run)..."
            /opt/airflow/dbt_venv/bin/dbt run
            
            echo ">> Proses dbt run selesai dengan sukses!"
        """
    )

    run_test_dbt = BashOperator(
        task_id="execute_dbt_tests",
        # Perintah bash multiline untuk pindah folder lalu mengeksekusi dbt
        bash_command=f"""
            echo ">> Memulai proses Consumer..."
            echo ">> Berpindah ke folder proyek dbt: {DBT_PROJECT_DIR}"
            cd {DBT_PROJECT_DIR}
            
            echo ">> Testing dbt model (dbt test)..."
            /opt/airflow/dbt_venv/bin/dbt test
            
            echo ">> Proses dbt test selesai dengan sukses!"
        """
    )

    # Menetapkan task ke dalam alur DAG (karena hanya ada satu task, cukup dipanggil)
    run_seed_dbt >> run_model_dbt >> run_test_dbt

# Inisialisasi DAG
dbt_consumer_pipeline()