import re
from typing import List

from src.model.task import Task


def parse_phone_number(big_string: str) -> List[str]:
  phone_numbers = []
  german_phone_number_pattern = "(?:\+49|0049)(\d{11})"

  for line in big_string.split(sep="\n"):
    
    phone_number = line.replace(" ", "")

    if re.match(german_phone_number_pattern, phone_number) is None:
      continue
    
    phone_numbers.append(phone_number)

  # dictionaries doesn't have duplication, then transform again in a list
  return list(dict.fromkeys(phone_numbers))
