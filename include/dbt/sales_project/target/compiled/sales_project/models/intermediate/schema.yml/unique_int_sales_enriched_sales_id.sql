
    
    

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
), dbt_test__target as (

  select sales_id as unique_field
  from __dbt__cte__int_sales_enriched
  where sales_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


