import json
import os
from src.helper.aws.client import get_aws_client

iam = get_aws_client("iam")


def create_role():
    # Define the policy document
    policy_document = {
        "Version": "2012-10-17",
        "Statement": [{"Effect": "Allow", "Action": ["*"], "Resource": "*"}],
    }

    # Create the policy
    policy_response = iam.create_policy(
        PolicyName="local-policy", PolicyDocument=json.dumps(policy_document)
    )

    iam.create_role(
        RoleName=os.environ["IAM_ROLE"],
        AssumeRolePolicyDocument=json.dumps(
            {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Effect": "Allow",
                        "Principal": {"Service": "events.amazonaws.com"},
                        "Action": "sts:AssumeRole",
                    }
                ],
            }
        ),
    )

    # Attach the policy to the role
    iam.attach_role_policy(
        RoleName=os.environ["IAM_ROLE"], PolicyArn=policy_response["Policy"]["Arn"]
    )


def delete_role():
    iam.detach_role_policy(
        RoleName=os.environ["IAM_ROLE"],
        PolicyArn="arn:aws:iam::000000000000:policy/local-policy",
    )

    iam.delete_policy(PolicyArn="arn:aws:iam::000000000000:policy/local-policy")

    iam.delete_role(RoleName=os.environ["IAM_ROLE"])
