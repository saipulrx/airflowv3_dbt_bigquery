
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select retention_rate
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`mart_customer_cohort`
where retention_rate is null



  
  
      
    ) dbt_internal_test