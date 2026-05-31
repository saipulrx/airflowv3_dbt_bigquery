-- Gold layer: Dimension
-- Tujuan: tabel dimensi customer enriched dengan lifetime metrics
--         dan region mapping dari lookup_region_mapping.

with  __dbt__cte__int_customer_metrics as (
-- Silver layer: Intermediate
-- Tujuan: hitung lifetime metrics per customer.
--         Base = stg_customer agar semua customer muncul,
--         termasuk yang belum pernah bertransaksi (Never Purchased).
--         Dipakai oleh dim_customer dan mart_customer_cohort.

with customer as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_customer`
),

sales as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_sales`
),

-- agregasi metrics hanya dari customer yang punya transaksi
sales_agg as (
    select
        customer_id,
        count(distinct sales_id)        as total_orders,
        sum(item_sold_qty)              as total_items_bought,
        sum(sales_amount)               as gross_revenue,
        sum(net_sales_amount)           as net_revenue,
        sum(discount_amount)            as total_discount_received,
        avg(net_sales_amount)           as avg_order_value,
        min(sales_date)                 as first_purchase_date,
        max(sales_date)                 as last_purchase_date
    from sales
    group by customer_id
),

customer_metrics as (
    select
        c.customer_id,

        -- volume (0 untuk customer tanpa transaksi)
        coalesce(sa.total_orders, 0)            as total_orders,
        coalesce(sa.total_items_bought, 0)      as total_items_bought,

        -- revenue (0 untuk customer tanpa transaksi)
        coalesce(sa.gross_revenue, 0)           as gross_revenue,
        coalesce(sa.net_revenue, 0)             as net_revenue,
        coalesce(sa.total_discount_received, 0) as total_discount_received,

        -- averages (NULL untuk customer tanpa transaksi — tidak ada AOV)
        sa.avg_order_value,

        -- tanggal aktivitas (NULL untuk customer tanpa transaksi)
        sa.first_purchase_date,
        sa.last_purchase_date,

        -- recency (NULL untuk customer tanpa transaksi)
        case
            when sa.last_purchase_date is null then null
            else date_diff(current_date(), sa.last_purchase_date, day)
        end                                     as days_since_last_purchase,

        -- segmentasi RFM Recency + flag Never Purchased
        case
            when sa.last_purchase_date is null                              then 'Never Purchased'
            when date_diff(current_date(), sa.last_purchase_date, day) <= 30  then 'Active'
            when date_diff(current_date(), sa.last_purchase_date, day) <= 90  then 'At Risk'
            when date_diff(current_date(), sa.last_purchase_date, day) <= 180 then 'Lapsed'
            else 'Churned'
        end                                     as recency_segment,

        -- flag eksplisit untuk filter cepat di downstream
        sa.customer_id is null                  as is_never_purchased

    from customer c
    left join sales_agg sa on c.customer_id = sa.customer_id
)

select * from customer_metrics
), customer as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_customer`
),

metrics as (
    select * from __dbt__cte__int_customer_metrics
),

region as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`lookup_region_mapping`
),

final as (
    select
        -- surrogate key
        to_hex(md5(cast(coalesce(cast(c.customer_id as string), '_dbt_utils_surrogate_key_null_') as string))) as customer_sk,

        -- natural key
        c.customer_id,

        -- attributes
        c.customer_name,
        c.email,
        c.address,
        c.city,
        c.country,
        c.gender,

        -- enrichment region dari seed
        r.province,
        r.region,
        r.island,
        r.is_tier1_city,

        -- lifetime metrics (dari intermediate)
        m.total_orders,
        m.total_items_bought,
        m.gross_revenue             as lifetime_gross_revenue,
        m.net_revenue               as lifetime_net_revenue,
        m.avg_order_value,
        m.first_purchase_date,
        m.last_purchase_date,
        m.days_since_last_purchase,
        m.recency_segment,

        -- segmentasi nilai customer
        case
            when m.total_orders = 0 or m.total_orders is null then 'Never Purchased'
            when m.net_revenue >= 10000000                    then 'High Value'
            when m.net_revenue >= 3000000                     then 'Mid Value'
            else 'Low Value'
        end                         as customer_value_segment,

        -- audit
        current_timestamp()         as dbt_updated_at

    from customer c
    left join metrics m on c.customer_id = m.customer_id
    left join region  r on lower(trim(c.city)) = lower(trim(r.city))
)

select * from final