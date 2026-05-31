
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select time_id_integer
from `dwh-bootcamp-bigquery`.`raw`.`raw_time`
where time_id_integer is null



  
  
      
    ) dbt_internal_test