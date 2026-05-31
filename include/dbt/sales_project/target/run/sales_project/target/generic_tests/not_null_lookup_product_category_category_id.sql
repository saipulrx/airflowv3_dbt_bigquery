
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select category_id
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`lookup_product_category`
where category_id is null



  
  
      
    ) dbt_internal_test