
    
    

with dbt_test__target as (

  select location_id_integer as unique_field
  from `dwh-bootcamp-bigquery`.`raw`.`raw_location`
  where location_id_integer is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


