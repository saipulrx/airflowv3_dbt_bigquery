
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with dbt_test__target as (

  select location_id_integer as unique_field
  from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`raw_location`
  where location_id_integer is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1



  
  
      
    ) dbt_internal_test