import json
from unittest import TestCase
from unittest.mock import patch
from src import app
from src.model.task import Task

from tests.utils import lambda_context, load_sample_event_from_file, load_sample_txt_from_file

@patch("aws_lambda_powertools.logging.Logger")
@patch("aws_lambda_powertools.metrics.Metrics")
@patch("aws_lambda_powertools.tracing.Tracer")
class TestCreateTask(TestCase):

  def setUp(self) -> None:
      self.event = load_sample_event_from_file()
      self.txt = load_sample_txt_from_file("phone_numbers_1")
      self.event["httpMethod"] = "POST"
      self.event["requestContext"]["httpMethod"] = "POST"
      self.event["rawPath"] = f"/task"
      self.event["path"] = f"/task"
      self.event["routeKey"] = f"POST /task"
      self.event["requestContext"]["path"] = f"/task"
  
  def test_create_task_throws_500(self, logger_mocked, metrics_mocked, tracing_mocked):
      with self.assertRaises(Exception):
        app.lambda_handler(event=self.event, context=lambda_context())
      
  
  def test_create_task_throws_400_no_german_phone_provided(self, logger_mocked, metrics_mocked, tracing_mocked):
    # given
    self.event["body"] = "john doe"
    
    # when
    response = app.lambda_handler(event=self.event, context=lambda_context())
    response_body = json.loads(response["body"])
    
    # then
    self.assertEqual(response["statusCode"], 400)
    self.assertEqual(response_body["message"], "No german phone numbers provided.")
  
  def test_create_task_returns_200(self, logger_mocked, metrics_mocked, tracing_mocked):
      # given
      self.event["body"] = self.txt
      
      # when
      response = app.lambda_handler(event=self.event, context=lambda_context())
      
      # then         
      self.assertEqual(response["statusCode"], 200)
