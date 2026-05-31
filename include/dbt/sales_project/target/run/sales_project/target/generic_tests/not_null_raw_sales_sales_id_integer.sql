
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select sales_id_integer
from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_seeds`.`raw_sales`
where sales_id_integer is null



  
  
      
    ) dbt_internal_test