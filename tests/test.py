from sys import _version_info
from unittest import TestCase

class TestA(TestCase):

  def test_version():
      assert _version_info == '0.1.0'
