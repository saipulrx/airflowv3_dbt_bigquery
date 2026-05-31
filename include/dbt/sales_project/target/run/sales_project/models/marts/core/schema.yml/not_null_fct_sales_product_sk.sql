
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_sk
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`fct_sales`
where product_sk is null



  
  
      
    ) dbt_internal_test