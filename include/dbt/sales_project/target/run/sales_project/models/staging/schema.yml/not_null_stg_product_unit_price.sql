
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select unit_price
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_product`
where unit_price is null



  
  
      
    ) dbt_internal_test