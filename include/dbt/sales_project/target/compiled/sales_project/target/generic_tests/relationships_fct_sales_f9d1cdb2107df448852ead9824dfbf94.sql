
    
    

with child as (
    select product_sk as from_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`fct_sales`
    where product_sk is not null
),

parent as (
    select product_sk as to_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_product`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


