-- Gold layer: Dimension
-- Tujuan: tabel dimensi waktu.
-- CATATAN: model ini menggunakan seed calendar sebagai sumber utama
--          karena kalender lebih lengkap dan konsisten.
--          Jika raw_time tersedia di source, ganti ref('calendar')
--          dengan ref('stg_time').

with time as (
    select * from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`calendar`
),

final as (
    select
        -- surrogate key
        to_hex(md5(cast(coalesce(cast(time_id as string), '_dbt_utils_surrogate_key_null_') as string))) as time_sk,

        -- natural key
        time_id,

        -- attributes
        full_date,
        day_of_month,
        month_number,
        month_name,
        year_number,
        day_name,
        is_weekend,
        quarter,
        year_month,

        -- audit
        current_timestamp()     as dbt_updated_at

    from time
)

select * from final