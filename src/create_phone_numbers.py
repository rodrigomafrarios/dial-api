from aws_lambda_powertools import Metrics, Tracer
from src.model.task import Task

tracer = Tracer()
metrics = Metrics(namespace="create_phone_numbers")

@tracer.capture_method
def lambda_handler(event, context):
  phone_numbers = event["detail"]["phone_numbers"]
  task_id = event["detail"]["task_id"]
  
  with Task.batch_write(auto_commit=True) as batch:
    for phone_number in phone_numbers:
      task = Task(id=task_id, phone_number=phone_number)
      batch.save(task)
