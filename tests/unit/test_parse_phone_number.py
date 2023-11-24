import random
import re
from unittest import TestCase
from src.helper.parse_phone_number import parse_phone_number

from tests.utils import load_sample_txt_from_file


class TestParsePhoneNumber(TestCase):
  def test_return_empty_list(self):
    
    # given
    txt = '''4797227953
            5301241153
            2098583407
            0097187434
            8679906790
            9401352020
            4572826504
            0125934593
            7691543804
            0035660727
          '''
    # when
    phone_numbers = parse_phone_number(big_string=txt)

    # then
    self.assertEqual(phone_numbers == [], True)
    self.assertEqual(len(phone_numbers) == 0, True)

  def test_non_german_phone_numbers(self):
    # given
    random_number = random.randrange(1, 10)
    self.txt = load_sample_txt_from_file(f"phone_numbers_{random_number}")

    german_phone_number_pattern = "(?:\+49|0049)(\d{11})"

    non_german_phone = ""

    for line in self.txt.split(sep="\n"):
    
      phone_number = line.replace(" ", "")

      if re.match(german_phone_number_pattern, phone_number) is None:
        non_german_phone = phone_number
        break
    
    # when
    phone_numbers = parse_phone_number(big_string=self.txt)

    # then
    self.assertEqual(non_german_phone not in phone_numbers, True)
  def test_return_list_phone_numbers(self):
    # given
    random_number = random.randrange(1, 10)
    self.txt = load_sample_txt_from_file(f"phone_numbers_{random_number}")

    # when
    phone_numbers = parse_phone_number(big_string=self.txt)

    # then
    self.assertIsNotNone(phone_numbers)
