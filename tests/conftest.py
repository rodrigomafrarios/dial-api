import os
import pytest
from tests.localstack.localstack_dynamodb import create_table, delete_table
from tests.localstack.localstack_eventbridge import create_rule, delete_rule
from tests.localstack.localstack_iam import create_role, delete_role



@pytest.fixture(scope="session", autouse=True)
def global_setup():
    print("\n----------------------- GLOBAL SETUP ----------------------\n")
    create_role()
    create_rule()
    create_table()
    yield

    print("\n----------------------- GLOBAL TEAR DOWN ----------------------\n")
    
    delete_table()
    delete_role()
    delete_rule()
    