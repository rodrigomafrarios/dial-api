import os
import boto3


def get_aws_client(service: str):
    if "AWS_ENDPOINT_URL" in os.environ:
        return boto3.client(service, endpoint_url=os.environ["AWS_ENDPOINT_URL"])
    return boto3.client(service)
