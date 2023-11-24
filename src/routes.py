from http import HTTPStatus
import json
import os
from uuid import uuid4
from aws_lambda_powertools import Logger, Metrics, Tracer
from aws_lambda_powertools.event_handler.api_gateway import Response, Router
from src.helper.aws.client import get_aws_client
from src.helper.parse_phone_number import parse_phone_number
from src.helper.response_wrapper import response_wrapper
from src.model.task import Task

eventbridge = get_aws_client(service="events")

logger = Logger()
tracer = Tracer()
router = Router()
metrics = Metrics(namespace="main")

@router.post("/task")
@tracer.capture_method
def create_task() -> Response:
  body = router.current_event.body

  logger.info(router.current_event)

  phone_numbers = parse_phone_number(big_string=body)

  if len(phone_numbers) == 0:
    return response_wrapper(status_code=HTTPStatus.BAD_REQUEST, data={ "message": "No german phone numbers provided." })

  task_id = str(uuid4())

  result = eventbridge.put_events(Entries=[{
    "Source": "api",
    "DetailType": "api.task.created",
    "EventBusName": os.environ["EVENT_BUS"],
    "Detail": json.dumps({
      "task_id": task_id,
      "phone_numbers": phone_numbers
    })
  }])

  logger.info(result)

  return response_wrapper(status_code=HTTPStatus.OK, data={ "task_id": task_id })

@router.get("/task/<task_id>")
@tracer.capture_method
def get_by_task_id(task_id: str) -> Response:
  try:
    phone_numbers = []
    for result in Task.query(index_name='GSI1', hash_key=task_id):
      phone_numbers.append(result.phone_number)

    if len(phone_numbers) == 0:
      return response_wrapper(status_code=HTTPStatus.NOT_FOUND)
    
    return response_wrapper(status_code=HTTPStatus.OK, data={
      "task": { "id": task_id, "phone_numbers": phone_numbers }
    })
  
  except StopIteration as task_not_found_error:
    logger.error(task_not_found_error)
    return response_wrapper(status_code=HTTPStatus.NOT_FOUND)

@router.delete("/task/<task_id>")
@tracer.capture_method
def delete_task(task_id: str) -> Response:
  
  # delete task
  with Task.batch_write(auto_commit=True) as batch:
    for task in Task.query(index_name='GSI1', hash_key=task_id):
      batch.delete(task)
  
  return response_wrapper(status_code=HTTPStatus.NO_CONTENT)

@router.get("/tasks")
@tracer.capture_method
def get_tasks() -> Response:
  return response_wrapper(status_code=HTTPStatus.OK, data={
    "task_ids": list(dict.fromkeys([task.id for task in Task.scan()]))
  })
