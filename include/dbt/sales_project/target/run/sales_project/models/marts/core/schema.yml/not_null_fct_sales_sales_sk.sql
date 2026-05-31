
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sales_sk
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`fct_sales`
where sales_sk is null



  
  
      
    ) dbt_internal_test