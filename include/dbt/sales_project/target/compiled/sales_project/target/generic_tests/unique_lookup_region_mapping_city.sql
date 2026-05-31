
    
    

with dbt_test__target as (

  select city as unique_field
  from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`lookup_region_mapping`
  where city is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


