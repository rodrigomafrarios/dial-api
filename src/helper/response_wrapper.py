
from datetime import datetime
from http import HTTPStatus
import json
from aws_lambda_powertools.event_handler.api_gateway import Response, content_types

def response_wrapper(status_code: HTTPStatus, data = None) -> Response:
    return Response(
        status_code=status_code,
        content_type=content_types.APPLICATION_JSON,
        body=json.dumps(data)
    )
