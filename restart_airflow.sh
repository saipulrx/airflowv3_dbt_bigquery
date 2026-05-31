#!/bin/bash

set -e

echo "=== [1/4] Menghentikan dan menghapus semua container + volume ==="
docker compose down --volumes --remove-orphans

echo ""
echo "=== [2/4] Build image dari Dockerfile ==="
docker compose build

echo ""
echo "=== [3/4] Inisialisasi database Airflow ==="
docker compose up airflow-init

echo ""
echo "=== [4/4] Menjalankan semua service ==="
docker compose up -d

echo ""
echo "=== Selesai! Airflow berjalan di http://localhost:8080 ==="