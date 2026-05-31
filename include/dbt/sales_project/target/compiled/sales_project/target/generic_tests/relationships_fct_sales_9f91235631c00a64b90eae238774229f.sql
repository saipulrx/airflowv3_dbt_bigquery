
    
    

with child as (
    select location_sk as from_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`fct_sales`
    where location_sk is not null
),

parent as (
    select location_sk as to_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_location`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


