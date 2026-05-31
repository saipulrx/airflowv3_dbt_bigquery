
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select time_id
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_time`
where time_id is null



  
  
      
    ) dbt_internal_test