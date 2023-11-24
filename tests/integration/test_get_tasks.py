import json
import random
from time import sleep
from unittest import TestCase
from unittest.mock import patch
from uuid import uuid4

import pytest
from src import app
from src.helper.parse_phone_number import parse_phone_number
from src.model.task import Task

from tests.utils import lambda_context, load_sample_event_from_file, load_sample_txt_from_file

@patch("aws_lambda_powertools.logging.Logger")
@patch("aws_lambda_powertools.metrics.Metrics")
@patch("aws_lambda_powertools.tracing.Tracer")
class TestGetByTaskId(TestCase):
  def setUp(self) -> None:
      self.event = load_sample_event_from_file()
      self.event["httpMethod"] = "GET"
      self.event["requestContext"]["httpMethod"] = "GET"
      self.event["rawPath"] = f"/tasks"
      self.event["path"] = f"/tasks"
      self.event["routeKey"] = f"GET /tasks"
      self.event["requestContext"]["path"] = f"/tasks"
  
  @patch("src.app.lambda_handler", side_effect=Exception)
  def test_get_task_ids_throws_500(self, logger_mocked, metrics_mocked, tracing_mocked, lambda_mocked):
     with self.assertRaises(Exception):
      app.lambda_handler(event=self.event, context=lambda_context())
    

  def test_get_task_ids_200(self, logger_mocked, metrics_mocked, tracing_mocked):

    # given
    random_number = random.randrange(1, 10)
    self.txt = load_sample_txt_from_file(f"phone_numbers_{random_number}")
    self.phone_numbers = parse_phone_number(big_string=self.txt)

    for task in Task.scan():
      task.delete()
    
    id = str(uuid4())
    task = Task(phone_number=self.phone_numbers[0], id=id)
    task.save()

    self.event["rawPath"] = f"/tasks"
    self.event["path"] = f"/tasks"
    self.event["routeKey"] = f"GET /tasks"
    self.event["requestContext"]["path"] = f"/tasks"

     # when
    response = app.lambda_handler(event=self.event, context=lambda_context())
    response_body = json.loads(response["body"])

    # then
    self.assertEqual(response["statusCode"], 200)
    self.assertEqual(len(response_body["task_ids"]) == 1, True)
    self.assertEqual(response_body["task_ids"][0] == id, True)

  def test_get_task_ids_200_empty(self, logger_mocked, metrics_mocked, tracing_mocked):

    # given
    self.event["rawPath"] = f"/tasks"
    self.event["path"] = f"/tasks"
    self.event["routeKey"] = f"GET /tasks"
    self.event["requestContext"]["path"] = f"/tasks"

    for task in Task.scan():
      task.delete()

     # when
    response = app.lambda_handler(event=self.event, context=lambda_context())
    response_body = json.loads(response["body"])

    # then
    self.assertEqual(response["statusCode"], 200)
    self.assertEqual(response_body["task_ids"], [])
