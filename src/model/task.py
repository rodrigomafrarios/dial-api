import datetime
import os
from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute, UTCDateTimeAttribute, UnicodeSetAttribute
from pynamodb.indexes import GlobalSecondaryIndex, AllProjection

class IdIndex(GlobalSecondaryIndex):
  class Meta:
    index_name = "GSI1"
    projection = AllProjection()

  id = UnicodeAttribute(hash_key=True)

class Task(Model):
    class Meta:
          region = os.environ["AWS_REGION"]
          table_name = os.environ["TABLE_NAME"]
          
    phone_number = UnicodeAttribute(hash_key=True)
    id = UnicodeAttribute(null=False)
    id_index = IdIndex()
    timestamp = UTCDateTimeAttribute(default_for_new=datetime.datetime.now(datetime.timezone.utc))
    