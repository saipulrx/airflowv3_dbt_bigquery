
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select city
from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`lookup_region_mapping`
where city is null



  
  
      
    ) dbt_internal_test