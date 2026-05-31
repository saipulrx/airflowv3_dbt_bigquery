
    
    

with all_values as (

    select
        price_tier as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_product`
    group by price_tier

)

select *
from all_values
where value_field not in (
    'Budget','Mid-range','Premium','Luxury'
)


