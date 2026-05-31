
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select time_sk
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_time`
where time_sk is null



  
  
      
    ) dbt_internal_test