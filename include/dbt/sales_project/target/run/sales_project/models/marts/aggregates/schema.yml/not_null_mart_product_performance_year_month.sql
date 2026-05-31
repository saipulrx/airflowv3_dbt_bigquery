
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select year_month
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`mart_product_performance`
where year_month is null



  
  
      
    ) dbt_internal_test