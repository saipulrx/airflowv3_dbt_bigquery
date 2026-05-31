
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sales_amount
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_sales`
where sales_amount is null



  
  
      
    ) dbt_internal_test