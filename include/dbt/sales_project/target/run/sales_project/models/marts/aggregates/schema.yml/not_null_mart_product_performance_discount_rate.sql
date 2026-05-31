
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select discount_rate
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`mart_product_performance`
where discount_rate is null



  
  
      
    ) dbt_internal_test