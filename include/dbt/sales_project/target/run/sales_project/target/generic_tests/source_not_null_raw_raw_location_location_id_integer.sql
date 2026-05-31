
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select location_id_integer
from `dwh-bootcamp-bigquery`.`raw`.`raw_location`
where location_id_integer is null



  
  
      
    ) dbt_internal_test