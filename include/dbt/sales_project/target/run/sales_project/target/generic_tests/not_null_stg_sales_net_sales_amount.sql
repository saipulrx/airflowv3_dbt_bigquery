
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select net_sales_amount
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_staging`.`stg_sales`
where net_sales_amount is null



  
  
      
    ) dbt_internal_test