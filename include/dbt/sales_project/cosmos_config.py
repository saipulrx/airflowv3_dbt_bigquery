from cosmos.config import ProfileConfig, ProjectConfig
from pathlib import Path

DBT_CONFIG = ProfileConfig(
    profile_name='sales_project',
    target_name='dev',
    profiles_yml_filepath=Path('/opt/airflow/include/dbt/sales_project/profiles.yml')
)

DBT_PROJECT_CONFIG = ProjectConfig(
    dbt_project_path=Path('/opt/airflow/include/dbt/sales_project/'),
)