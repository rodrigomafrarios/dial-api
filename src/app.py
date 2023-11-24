import json
import os
from aws_lambda_powertools.utilities.data_classes import (
    APIGatewayProxyEvent,
    event_source,
)
from aws_lambda_powertools.event_handler import APIGatewayRestResolver, content_types
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler.api_gateway import Response
from aws_lambda_powertools.logging import correlation_paths
from botocore.exceptions import ClientError
import src.routes as tasks
logger = Logger()
tracer = Tracer()

app = APIGatewayRestResolver()
app.include_router(tasks.router)

@logger.inject_lambda_context(correlation_id_path=correlation_paths.API_GATEWAY_REST)
@event_source(data_class=APIGatewayProxyEvent)
@tracer.capture_lambda_handler(capture_response=False)
def lambda_handler(event: APIGatewayProxyEvent, context: LambdaContext):
    logger.append_keys(path=event.path)
    tracer.put_annotation("method", event.http_method)
    tracer.put_annotation("path", event.path)
    app.append_context(
        region=os.environ["AWS_REGION"],
        account_id=context.invoked_function_arn.split(":")[4],
    )

    return app.resolve(event, context)

@app.exception_handler(ClientError)
def handle_botocore_error(exception: ClientError):
    logger.error("Exception: %s", exception)
    match exception.response["Error"]["Code"]:
        case "NotFoundError":
            return Response(
                status_code=404,
                content_type=content_types.APPLICATION_JSON,
                body=json.dumps(
                    {
                        "statusCode": 404,
                        "message": exception.response["Error"]["Message"],
                    }
                ),
            )
        case "ResourceNotFoundException":
            # Failure gets raised when AWS resource cannot be found
            return Response(
                status_code=404,
                content_type=content_types.APPLICATION_JSON,
                body=json.dumps(
                    {
                        "statusCode": 404,
                        "message": exception.response["Error"]["Message"],
                    }
                ),
            )
        case "ConditionalCheckFailedException":
            logger.error(exception.response["Error"]["Message"])
            return Response(
                status_code=403,
                content_type=content_types.APPLICATION_JSON,
                body=json.dumps(
                    {
                        "statusCode": 403,
                        "message": "Forbidden",
                    }
                ),
            )
        case _:
            return Response(
                status_code=500,
                content_type=content_types.APPLICATION_JSON,
                body=json.dumps(
                    {"statusCode": 500, "message": "Internal server error"}
                ),
            )
