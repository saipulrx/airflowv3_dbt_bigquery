
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select email
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`raw_customer`
where email is null



  
  
      
    ) dbt_internal_test