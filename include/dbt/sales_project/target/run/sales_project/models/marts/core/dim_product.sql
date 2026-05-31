
  
    

    create or replace table `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_product`
      
    
    

    
    OPTIONS()
    as (
      -- Gold layer: Dimension
-- Tujuan: tabel dimensi produk enriched dengan deskripsi kategori
--         dari lookup_product_category.

with product as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_product`
),

category as (
    select * from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`lookup_product_category`
    where is_active = true
),

final as (
    select
        -- surrogate key
        to_hex(md5(cast(coalesce(cast(product_id as string), '_dbt_utils_surrogate_key_null_') as string))) as product_sk,

        -- natural key
        p.product_id,

        -- attributes
        p.product_name,
        p.product_category,
        p.product_subcategory,
        p.brand,
        p.unit_price,
        p.stock_qty,

        -- enrichment dari lookup_product_category
        c.category_description,

        -- derived
        case
            when p.unit_price < 100000   then 'Budget'
            when p.unit_price < 500000   then 'Mid-range'
            when p.unit_price < 2000000  then 'Premium'
            else 'Luxury'
        end                             as price_tier,

        -- audit
        current_timestamp()             as dbt_updated_at

    from product p
    left join category c
        on  lower(trim(p.product_category))    = lower(trim(c.product_category))
        and lower(trim(p.product_subcategory)) = lower(trim(c.product_subcategory))
)

select * from final
    );
  