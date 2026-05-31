
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select product_id_integer
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`raw_product`
where product_id_integer is null



  
  
      
    ) dbt_internal_test