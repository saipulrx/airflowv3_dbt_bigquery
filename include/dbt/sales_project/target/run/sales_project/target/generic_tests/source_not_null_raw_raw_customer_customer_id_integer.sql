
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select customer_id_integer
from `dwh-bootcamp-bigquery`.`raw`.`raw_customer`
where customer_id_integer is null



  
  
      
    ) dbt_internal_test