
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select time_sk as from_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`fct_sales`
    where time_sk is not null
),

parent as (
    select time_sk as to_field
    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_time`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test