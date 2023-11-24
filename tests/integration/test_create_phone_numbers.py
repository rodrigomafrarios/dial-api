import random
from unittest import TestCase
from unittest.mock import patch
from uuid import uuid4
from src.create_phone_numbers import lambda_handler
from src.helper.parse_phone_number import parse_phone_number
from src.model.task import Task

from tests.utils import lambda_context, load_sample_txt_from_file

@patch("aws_lambda_powertools.logging.Logger")
@patch("aws_lambda_powertools.metrics.Metrics")
@patch("aws_lambda_powertools.tracing.Tracer")
class TestCreatePhoneNumbers(TestCase):

  def setUp(self) -> None:
      
      random_number = random.randrange(1, 10)

      self.txt = load_sample_txt_from_file(f"phone_numbers_{random_number}")
      self.phone_numbers = parse_phone_number(big_string=self.txt)
      
  
  def test_create_phone_numbers_throws_500(self, logger_mocked, metrics_mocked, tracing_mocked):
      # given
      event = {
         'version': '0', 
         'id': str(uuid4()), 
         'detail-type': 'api.task.created', 
         'source': 'api', 
         'account': '123445134842', 
         'time': '2023-11-22T19:46:24Z',
         'region': 'eu-central-1', 
         'resources': [], 
         'detail': {'phone_numbers': []}
      }

      # when/then
      with self.assertRaises(Exception):
        lambda_handler(event=event, context=lambda_context())
  
  def test_create_phone_numbers_returns_200(self, logger_mocked, metrics_mocked, tracing_mocked):
      # given
      id = str(uuid4())
      event = {
         'version': '0', 
         'id': "", 
         'detail-type': 'api.task.created', 
         'source': 'api', 
         'account': '123445134842', 
         'time': '2023-11-22T19:46:24Z',
         'region': 'eu-central-1', 
         'resources': [], 
         'detail': {'phone_numbers': self.phone_numbers[0:5], 'task_id': id}
      }

      tasks_before = []

      for task in Task.query(index_name='GSI1', hash_key=id, limit=1):
         tasks_before.append(task.id)

      # when
      lambda_handler(event=event, context=lambda_context())

      tasks_after = []

      for task in Task.query(index_name='GSI1', hash_key=id, limit=1):
         tasks_after.append(task.id)
      
      # then
      self.assertEqual(len(tasks_before) == 0, True)
      self.assertEqual(len(tasks_after) == 1, True)
