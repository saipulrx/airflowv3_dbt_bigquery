
    
    

with dbt_test__target as (

  select time_id as unique_field
  from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_time`
  where time_id is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


