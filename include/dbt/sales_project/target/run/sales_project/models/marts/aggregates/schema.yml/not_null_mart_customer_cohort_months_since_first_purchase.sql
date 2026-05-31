
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select months_since_first_purchase
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`mart_customer_cohort`
where months_since_first_purchase is null



  
  
      
    ) dbt_internal_test