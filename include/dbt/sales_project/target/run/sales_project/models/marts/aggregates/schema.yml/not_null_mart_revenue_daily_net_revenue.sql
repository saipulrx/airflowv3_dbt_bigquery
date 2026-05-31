
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select net_revenue
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`mart_revenue_daily`
where net_revenue is null



  
  
      
    ) dbt_internal_test