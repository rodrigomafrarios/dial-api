from aws_lambda_powertools.utilities.parser import BaseModel
from pydantic import StrictStr

class CreateTask(BaseModel):
  phone_number: StrictStr
  
