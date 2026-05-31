
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        gender as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_staging`.`stg_customer`
    group by gender

)

select *
from all_values
where value_field not in (
    'M','F','MALE','FEMALE','OTHER'
)



  
  
      
    ) dbt_internal_test