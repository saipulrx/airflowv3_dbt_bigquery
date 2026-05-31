
    
    

with dbt_test__target as (

  select customer_id_integer as unique_field
  from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`raw_customer`
  where customer_id_integer is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


