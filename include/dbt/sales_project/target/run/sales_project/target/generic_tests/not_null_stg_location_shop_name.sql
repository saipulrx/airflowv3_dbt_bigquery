
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select shop_name
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_staging`.`stg_location`
where shop_name is null



  
  
      
    ) dbt_internal_test