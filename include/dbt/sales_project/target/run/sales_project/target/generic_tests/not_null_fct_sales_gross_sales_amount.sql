
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select gross_sales_amount
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`fct_sales`
where gross_sales_amount is null



  
  
      
    ) dbt_internal_test