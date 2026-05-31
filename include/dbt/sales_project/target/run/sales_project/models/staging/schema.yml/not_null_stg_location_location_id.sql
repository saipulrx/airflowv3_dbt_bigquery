
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select location_id
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_location`
where location_id is null



  
  
      
    ) dbt_internal_test