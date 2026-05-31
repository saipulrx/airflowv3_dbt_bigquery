
    
    

with dbt_test__target as (

  select product_id_integer as unique_field
  from `dwh-bootcamp-bigquery`.`latihan_dwh_bq_dbt_seeds`.`raw_product`
  where product_id_integer is not null

)

select
    unique_field,
    count(*) as n_records

from dbt_test__target
group by unique_field
having count(*) > 1


