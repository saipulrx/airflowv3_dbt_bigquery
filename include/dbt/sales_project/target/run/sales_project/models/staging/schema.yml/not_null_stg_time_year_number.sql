
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select year_number
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_time`
where year_number is null



  
  
      
    ) dbt_internal_test