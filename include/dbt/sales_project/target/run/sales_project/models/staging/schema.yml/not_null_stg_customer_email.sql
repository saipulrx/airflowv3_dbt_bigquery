
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select email
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_customer`
where email is null



  
  
      
    ) dbt_internal_test