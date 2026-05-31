# 🌬️ Apache Airflow v3 + dbt Core + BigQuery

Repository ini berisi konfigurasi lengkap untuk menjalankan pipeline ELT menggunakan **Apache Airflow 3.x** sebagai orkestrator dan **dbt Core** sebagai transformation tool, dengan **Google BigQuery** sebagai data warehouse. Semua komponen dijalankan menggunakan Docker Compose dengan arsitektur **CeleryExecutor**.

---

## 📋 Daftar Isi

- [Arsitektur](#arsitektur)
- [Tech Stack](#tech-stack)
- [Prasyarat](#prasyarat)
- [Struktur Direktori](#struktur-direktori)
- [Konfigurasi Environment](#konfigurasi-environment)
- [Konfigurasi BigQuery](#konfigurasi-bigquery)
- [Cara Menjalankan](#cara-menjalankan)
- [Struktur dbt Project](#struktur-dbt-project)
- [Menulis DAG untuk dbt](#menulis-dag-untuk-dbt)
- [Akses UI](#akses-ui)
- [Menghentikan Layanan](#menghentikan-layanan)
- [Troubleshooting](#troubleshooting)
- [Referensi](#referensi)

---

## 🏗️ Arsitektur

```
                          ┌──────────────────┐
                          │   User / Browser  │
                          └────────┬─────────┘
                                   │ HTTP :8080
                    ┌──────────────▼──────────────┐
                    │         API Server           │
                    │    Web UI + REST API (:8080) │
                    └───────┬──────────┬───────────┘
                            │          │
               ┌────────────▼──┐   ┌───▼──────────────────┐
               │   Scheduler   │   │    DAG Processor       │
               │  Jadwalkan &  │   │  Parse & serialize     │
               │  trigger task │   │  DAG files ★ new v3   │
               └──────┬────────┘   └───────────┬───────────┘
                      │                         │
               ┌──────▼────────┐        ┌───────▼────────┐
               │  Redis :6379  │        │   Volume dags/  │
               │ Celery broker │        │  File Python    │
               └──┬────────────┘        │  DAG kamu       │
                  │                     └────────────────-┘
       ┌──────────┼──────────┐
       ▼          ▼          ▼                  ┌───────────┐
  ┌─────────┐┌─────────┐┌─────────┐            │ Triggerer │
  │Worker 1 ││Worker 2 ││Worker N ││            │  Deferred │
  │  Celery ││  Celery ││  Celery ││            │   tasks   │
  └────┬────┘└────┬────┘└────┬────┘            └─────┬─────┘
       │  BashOp  │  BashOp  │                        │
       │ dbt run  │ dbt run  │                        │
       └──────────┴──────────┴────────────────────────┘
                                    │
                    ┌───────────────▼──────────────────┐
                    │          PostgreSQL :5432          │
                    │  Metadata DB — DAG runs, task     │
                    │  instances, logs, koneksi, variabel│
                    └───────────────────────────────────┘
                                    │
                                    │ dbt run / seed / test
                                    ▼
                    ┌───────────────────────────────────┐
                    │        Google BigQuery             │
                    │  Data Warehouse — staging, mart   │
                    └───────────────────────────────────┘
```

> **★ Perubahan utama Airflow v3:** DAG Processor kini berjalan sebagai **service terpisah** dari Scheduler. dbt diinstall di dalam **virtual environment terpisah** (`dbt_venv`) di dalam container untuk menghindari konflik dependency dengan Airflow.

### Komponen Docker Services

| Service | Fungsi |
|---|---|
| `postgres` | Database backend metadata Airflow (PostgreSQL 16) |
| `redis` | Message broker untuk CeleryExecutor (Redis 7.2) |
| `airflow-apiserver` | API Server & Web UI Airflow (port 8080) |
| `airflow-scheduler` | Menjadwalkan dan memicu task |
| `airflow-dag-processor` | Memproses dan mem-parse file DAG (**baru di Airflow 3**) |
| `airflow-worker` | Celery worker yang mengeksekusi dbt commands |
| `airflow-triggerer` | Menangani deferred/async tasks |
| `airflow-init` | Inisialisasi database dan user admin |
| `flower` *(opsional)* | Monitoring Celery worker (port 5555) |

### Alur Eksekusi ELT

1. User men-trigger DAG melalui **Web UI** atau **REST API**.
2. **DAG Processor** membaca file Python DAG dari folder `dags/`.
3. **Scheduler** mengirim task ke antrian **Redis**.
4. **Celery Worker** mengambil task dan menjalankan perintah dbt (`dbt seed`, `dbt run`, `dbt test`) menggunakan binary dari `/opt/airflow/dbt_venv/bin/dbt`.
5. dbt terhubung ke **Google BigQuery** dan menjalankan transformasi SQL.
6. Hasil dan log disimpan ke **PostgreSQL** dan BigQuery.

---

## 🛠️ Tech Stack

| Komponen | Teknologi | Versi |
|---|---|---|
| Orkestrator | Apache Airflow | 3.2.2 |
| Executor | CeleryExecutor + Redis | Redis 7.2 |
| Transformation | dbt Core | 1.11.x |
| Adapter | dbt-bigquery | 1.11.0 |
| Data Warehouse | Google BigQuery | - |
| Database Metadata | PostgreSQL | 16 |
| Container | Docker Compose | 2.x+ |

---

## ✅ Prasyarat

Pastikan sudah terinstal di mesin Anda:

- [Docker](https://docs.docker.com/get-docker/) versi 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) versi 2.x+
- Google Cloud Project dengan BigQuery API aktif
- Service Account Google Cloud dengan role **BigQuery Data Editor** dan **BigQuery Job User**
- Minimal **4 GB RAM** tersedia untuk Docker
- Minimal **2 CPU** tersedia untuk Docker
- Minimal **15 GB** ruang disk kosong (lebih besar karena dbt-bigquery dependencies)

---

## 📁 Struktur Direktori

```
airflowv3_dbt_bigquery/
├── config/                      # Konfigurasi Airflow (airflow.cfg)
├── dags/                        # File DAG Airflow
│   └── elt_dbt.py               # Contoh DAG untuk menjalankan dbt
├── include/
│   └── dbt/
│       └── sales_project/       # dbt project
│           ├── dbt_project.yml
│           ├── profiles.yml     # Konfigurasi koneksi BigQuery
│           ├── models/
│           │   ├── staging/     # Model staging (stg_*)
│           │   └── marts/       # Model mart (mart_*)
│           └── seeds/           # File CSV seed data
├── logs/                        # Log eksekusi (auto-generated)
├── .env                         # Environment variables
├── .gitignore
├── Dockerfile                   # Custom image dengan dbt terinstall
├── docker-compose.yaml
├── restart_airflow.sh           # Script helper untuk rebuild
└── README.md
```

---

## ⚙️ Konfigurasi Environment

File `.env` berisi variabel-variabel penting. Buat file ini sebelum menjalankan stack.

| Variabel | Keterangan | Default |
|---|---|---|
| `AIRFLOW_UID` | UID user di dalam container | `50000` |
| `AIRFLOW_PROJ_DIR` | Path direktori project | `.` |
| `FERNET_KEY` | Kunci enkripsi koneksi & variabel | *wajib diisi* |
| `AIRFLOW__API_AUTH__JWT_SECRET` | Secret JWT untuk autentikasi API | `airflow_jwt_secret` |
| `_AIRFLOW_WWW_USER_USERNAME` | Username admin UI | `airflow` |
| `_AIRFLOW_WWW_USER_PASSWORD` | Password admin UI | `airflow` |

**Generate Fernet Key:**

```bash
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

**Set AIRFLOW_UID (Linux/Mac):**

```bash
echo "AIRFLOW_UID=$(id -u)" >> .env
```

---

## 🔑 Konfigurasi BigQuery

### 1. Buat Service Account

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Masuk ke **IAM & Admin → Service Accounts**
3. Buat service account baru dengan role:
   - `BigQuery Data Editor`
   - `BigQuery Job User`
4. Download key dalam format **JSON**
5. Simpan file key di dalam folder `include/` (contoh: `include/gcp_keyfile.json`)

### 2. Konfigurasi dbt profiles.yml

Edit file `include/dbt/sales_project/profiles.yml`:

```yaml
sales_project:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: YOUR_GCP_PROJECT_ID
      dataset: YOUR_BIGQUERY_DATASET
      keyfile: /opt/airflow/include/gcp_keyfile.json
      threads: 4
      timeout_seconds: 300
      location: asia-southeast2  # sesuaikan dengan region kamu
```

---

## 🚀 Cara Menjalankan

### Cara 1 — Menggunakan script otomatis (direkomendasikan untuk fresh start)

```bash
chmod +x restart_airflow.sh
./restart_airflow.sh
```

Script ini akan menjalankan secara berurutan: `down --volumes` → `build --no-cache` → `airflow-init` → `up -d`.

### Cara 2 — Manual step by step

**Step 1: Build custom Docker image**

```bash
docker compose build
```

> Proses build memakan waktu 15–45 menit tergantung koneksi internet karena mengunduh `dbt-bigquery` dan dependencies-nya (pyarrow ~45MB, grpcio, dll).

**Step 2: Inisialisasi database Airflow**

```bash
docker compose up airflow-init
```

**Step 3: Jalankan semua services**

```bash
docker compose up -d
```

**Step 4: Cek status services**

```bash
docker compose ps
```

**Step 5: (Opsional) Jalankan Flower untuk monitoring Celery**

```bash
docker compose --profile flower up -d
```

### Melihat log

```bash
# Semua services
docker compose logs -f

# Service tertentu
docker compose logs -f airflow-worker
docker compose logs -f airflow-scheduler
```

---

## 🌿 Struktur dbt Project

dbt project berada di `include/dbt/sales_project/` dengan struktur layer:

```
sales_project/
├── dbt_project.yml
├── profiles.yml
├── seeds/              # Raw data CSV yang di-load ke BigQuery
├── models/
│   ├── staging/        # Layer 1: Bersihkan & standardisasi data mentah
│   │   └── stg_*.sql
│   └── marts/          # Layer 2: Model siap pakai untuk analitik
│       └── mart_*.sql
└── tests/              # Data quality tests
```

**Menjalankan dbt secara manual di dalam container:**

```bash
# Masuk ke container worker
docker exec -it <nama_container_worker> bash

# Jalankan dbt menggunakan venv
/opt/airflow/dbt_venv/bin/dbt run --project-dir /opt/airflow/include/dbt/sales_project/
/opt/airflow/dbt_venv/bin/dbt test --project-dir /opt/airflow/include/dbt/sales_project/
```

---

## ✍️ Menulis DAG untuk dbt

Gunakan `BashOperator` dengan path lengkap ke binary dbt di dalam venv:

```python
from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from datetime import datetime

DBT_PROJECT_DIR = "/opt/airflow/include/dbt/sales_project"
DBT_BIN = "/opt/airflow/dbt_venv/bin/dbt"

@dag(
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['dbt', 'bigquery'],
)
def elt_dbt():
    dbt_seed = BashOperator(
        task_id='dbt_seed',
        bash_command=f'cd {DBT_PROJECT_DIR} && {DBT_BIN} seed'
    )
    dbt_run_staging = BashOperator(
        task_id='dbt_run_staging',
        bash_command=f'cd {DBT_PROJECT_DIR} && {DBT_BIN} run --select staging'
    )
    dbt_run_marts = BashOperator(
        task_id='dbt_run_marts',
        bash_command=f'cd {DBT_PROJECT_DIR} && {DBT_BIN} run --select marts'
    )
    dbt_test = BashOperator(
        task_id='dbt_test',
        bash_command=f'cd {DBT_PROJECT_DIR} && {DBT_BIN} test'
    )
    dbt_seed >> dbt_run_staging >> dbt_run_marts >> dbt_test

elt_dbt()
```

> **Penting:** Selalu gunakan path lengkap `/opt/airflow/dbt_venv/bin/dbt` — jangan hanya `dbt`, karena dbt terinstall di dalam virtual environment terpisah, bukan di PATH utama Airflow.

---

## 🌐 Akses UI

Setelah semua service berjalan (tunggu sekitar 1–2 menit):

| Interface | URL | Kredensial Default |
|---|---|---|
| **Airflow Web UI** | http://localhost:8080 | `airflow` / `airflow` |
| **Flower (Celery Monitor)** | http://localhost:5555 | *(tanpa auth)* |

---

## 🛑 Menghentikan Layanan

```bash
# Hentikan semua container (data tetap tersimpan)
docker compose down

# Hentikan dan hapus semua data termasuk database (fresh start)
docker compose down --volumes --remove-orphans
```

---

## 🔧 Troubleshooting

**Error: `dbt: command not found`**

Pastikan menggunakan path lengkap di `bash_command`:
```python
bash_command='cd /opt/airflow/include/dbt/sales_project && /opt/airflow/dbt_venv/bin/dbt run'
```

**Error: `ImportError: cannot import name 'conf'` (cosmos circular import)**

Ini terjadi jika menginstall `astronomer-cosmos` yang belum kompatibel dengan Airflow 3. Repo ini tidak menggunakan cosmos — gunakan `BashOperator` langsung seperti contoh di atas.

**Build sangat lama (>30 menit)**

Normal terjadi pada build pertama karena `dbt-bigquery` menarik banyak dependency besar (pyarrow 45MB+, grpcio). Build berikutnya akan lebih cepat karena Docker cache.

**Error koneksi BigQuery**

Pastikan path `keyfile` di `profiles.yml` sudah benar dan service account memiliki role yang tepat.

---

## 📚 Referensi

- [Dokumentasi Resmi Apache Airflow](https://airflow.apache.org/docs/)
- [Airflow 3 Migration Guide](https://airflow.apache.org/docs/apache-airflow/stable/migration-guide.html)
- [dbt Core Documentation](https://docs.getdbt.com/docs/core/installation-overview)
- [dbt-bigquery Adapter](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)
- [Google BigQuery Documentation](https://cloud.google.com/bigquery/docs)