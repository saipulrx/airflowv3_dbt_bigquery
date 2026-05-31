
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sales_id
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_staging`.`stg_sales`
where sales_id is null



  
  
      
    ) dbt_internal_test