
    
    

with dbt_test__target as (

  select sales_id as unique_field
  from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`fct_sales`
  where sales_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


