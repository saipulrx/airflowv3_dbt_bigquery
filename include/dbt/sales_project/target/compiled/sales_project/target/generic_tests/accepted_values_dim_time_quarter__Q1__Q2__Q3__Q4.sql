
    
    

with all_values as (

    select
        quarter as value_field,
        count(*) as n_records

    from `dwh-bootcamp-bigquery`.`workshop_dwh_bq_dbt_marts`.`dim_time`
    group by quarter

)

select *
from all_values
where value_field not in (
    'Q1','Q2','Q3','Q4'
)


