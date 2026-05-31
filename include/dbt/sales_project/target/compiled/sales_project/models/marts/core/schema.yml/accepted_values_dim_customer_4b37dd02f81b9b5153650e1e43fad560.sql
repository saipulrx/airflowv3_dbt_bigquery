
    
    

with all_values as (

    select
        recency_segment as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_marts`.`dim_customer`
    group by recency_segment

)

select *
from all_values
where value_field not in (
    'Active','At Risk','Lapsed','Churned','Never Purchased'
)


