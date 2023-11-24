from dataclasses import dataclass
import json
import warnings

def load_sample_event_from_file() -> dict:
    """
    Loads and validate test events from the file system
    """
    warnings.filterwarnings("ignore", category=UserWarning)
    event_file_name = f"tests/sample_event.json"
    with open(event_file_name, "r", encoding="UTF-8") as file_handle:
        event = json.load(file_handle)
        return event

def load_sample_txt_from_file(test_event_file_name: str) -> str:
    """
    Loads and validate test events from the file system
    """
    warnings.filterwarnings("ignore", category=UserWarning)
    event_file_name = f"tests/txt/{test_event_file_name}.txt"

    with open(event_file_name, "r", encoding="UTF-8") as file_handle:
        return file_handle.read()


def lambda_context():
    @dataclass
    class LambdaContext:
        function_name: str = "test"
        memory_limit_in_mb: int = 128
        invoked_function_arn: str = "arn:aws:lambda:eu-west-1:0123456789:function:test"
        aws_request_id: str = "52fdfc07-2182-154f-163f-5f0f9a621d72"

    return LambdaContext()
