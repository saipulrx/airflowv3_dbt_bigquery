
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        recency_segment as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_customer`
    group by recency_segment

)

select *
from all_values
where value_field not in (
    'Active','At Risk','Lapsed','Churned','Never Purchased'
)



  
  
      
    ) dbt_internal_test