
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_id
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_sales`
where product_id is null



  
  
      
    ) dbt_internal_test