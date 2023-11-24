import json
import os
from src.helper.aws.client import get_aws_client

eventbridge = get_aws_client("events")


def create_rule():
    eventbridge.create_event_bus(Name=os.environ["EVENT_BUS"])
    return eventbridge.put_rule(
        Name="test",
        EventBusName=os.environ["EVENT_BUS"],
        RoleArn=f'arn:aws:iam::000000000000:role/{os.environ["IAM_ROLE"]}',
        EventPattern=json.dumps({
            "source": ["api"],
            "detail-type": ["api.task.created"]
        })
    )

def delete_rule():
    eventbridge.delete_rule(Name="test", EventBusName=os.environ["EVENT_BUS"])
    eventbridge.delete_event_bus(Name=os.environ["EVENT_BUS"])
