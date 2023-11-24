import os

from src.helper.aws.client import get_aws_client


dynamodb = get_aws_client("dynamodb")


def exists() -> bool:
    results = dynamodb.list_tables(Limit=1)
    return (
        len(results["TableNames"]) > 0
        and results["TableNames"][0] == os.environ["TABLE_NAME"]
    )


def create_table():
    table_exists = exists()

    if table_exists:
        return

    dynamodb.create_table(
        TableName=os.environ["TABLE_NAME"],
        AttributeDefinitions=[
            {"AttributeName": "phone_number", "AttributeType": "S"},
            {"AttributeName": "id", "AttributeType": "S"},
        ],
        KeySchema=[
            {"AttributeName": "phone_number", "KeyType": "HASH"},
        ],
        GlobalSecondaryIndexes=[
            {
                "IndexName": "GSI1",
                "KeySchema": [
                    {"AttributeName": "id", "KeyType": "HASH"}
                ],
                "Projection": {
                    "ProjectionType": "ALL",
                },
                "ProvisionedThroughput": {
                    "ReadCapacityUnits": 123,
                    "WriteCapacityUnits": 123,
                }
            }
        ],
        ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5},
    )


def delete_table():
    dynamodb.delete_table(TableName=os.environ["TABLE_NAME"])
