
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        customer_value_segment as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_customer`
    group by customer_value_segment

)

select *
from all_values
where value_field not in (
    'High Value','Mid Value','Low Value','Never Purchased'
)



  
  
      
    ) dbt_internal_test