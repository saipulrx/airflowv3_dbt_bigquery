-- Gold layer: Fact
-- Tujuan: tabel fakta transaksi penjualan di grain 1 baris = 1 transaksi.
--         Join ke surrogate key dari semua dim table.

with  __dbt__cte__int_sales_enriched as (
-- Silver layer: Intermediate
-- Tujuan: join semua staging model menjadi satu enriched sales table.
--         Berisi logika bisnis dasar yang dipakai oleh banyak model Gold.
--         Materialized sebagai ephemeral (tidak ada tabel fisik di warehouse).

with sales as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_sales`
),

product as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_product`
),

customer as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_customer`
),

time as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_time`
),

location as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_location`
),

enriched as (
    select
        -- keys
        s.sales_id,
        s.product_id,
        s.customer_id,
        s.time_id,
        s.location_id,

        -- tanggal
        s.sales_date,
        s.sales_datetime,
        t.full_date,
        t.day_of_month,
        t.month_number,
        t.month_name,
        t.year_number,
        t.day_name,
        t.is_weekend,

        -- product
        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.brand,
        p.unit_price,

        -- customer
        c.customer_name,
        c.city             as customer_city,
        c.country          as customer_country,
        c.gender,

        -- location
        l.shop_name,
        l.shop_city,
        l.shop_province,
        l.shop_country,

        -- measures
        s.item_sold_qty,
        s.discount_amount,
        s.sales_amount,
        s.net_sales_amount,

        -- derived metrics
        s.net_sales_amount / nullif(s.item_sold_qty, 0) as avg_selling_price,

        -- repeat purchase flag: apakah ini bukan transaksi pertama customer?
        row_number() over (
            partition by s.customer_id
            order by s.sales_date, s.sales_id
        )                                               as customer_order_sequence,

        case
            when row_number() over (
                partition by s.customer_id
                order by s.sales_date, s.sales_id
            ) > 1 then true
            else false
        end                                             as is_repeat_purchase

    from sales s
    left join product  p on s.product_id  = p.product_id
    left join customer c on s.customer_id = c.customer_id
    left join time     t on s.time_id     = t.time_id
    left join location l on s.location_id = l.location_id
)

select * from enriched
), enriched as (
    select * from __dbt__cte__int_sales_enriched
),

dim_product as (
    select product_id, product_sk from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_product`
),

dim_customer as (
    select customer_id, customer_sk from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_customer`
),

dim_time as (
    select time_id, time_sk from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_time`
),

dim_location as (
    select location_id, location_sk from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_location`
),

final as (
    select
        -- surrogate key fakta
        to_hex(md5(cast(coalesce(cast(e.sales_id as string), '_dbt_utils_surrogate_key_null_') as string))) as sales_sk,

        -- natural key
        e.sales_id,

        -- foreign keys ke dimensi (surrogate key)
        dp.product_sk,
        dc.customer_sk,
        dt.time_sk,
        dl.location_sk,

        -- degenerate dimensions (tidak perlu dim table sendiri)
        e.sales_date,
        e.sales_datetime,

        -- measures additive
        e.item_sold_qty,
        e.discount_amount,
        e.sales_amount          as gross_sales_amount,
        e.net_sales_amount,

        -- measures semi-additive / derived
        e.avg_selling_price,
        e.unit_price            as listed_unit_price,

        -- flags bisnis
        e.is_repeat_purchase,
        e.customer_order_sequence,

        -- audit
        current_timestamp()     as dbt_updated_at

    from enriched e
    left join dim_product  dp on e.product_id  = dp.product_id
    left join dim_customer dc on e.customer_id = dc.customer_id
    left join dim_time     dt on e.time_id     = dt.time_id
    left join dim_location dl on e.location_id = dl.location_id
)

select * from final