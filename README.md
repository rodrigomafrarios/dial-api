[] TODO: Terraform Infrastructure

- API Gateway
- Proxy lambda {proxy+}
- dynamodb table
- IAM Roles
- IAM Permissions

Output: Api gateway endpoint

[] TODO: Data Model

`TaskModel(BaseModel):`

- task_id: uuid4 (PK/SK)
- phone_number: str (GSI1)
- created_at: str

# APIS

Setup lambda powertools

- [] Data validation
- [] Error handling

[] TODO: 1. `create_task() -> Response` Endpoint

Description:
Submit a file to the endpoint to be processed

INPUT: Submit a file to the endpoint to be processed. Example files are provided, see phone_numbers_1.txt phone_numbers_2.txt phone_numbers_3.txt

- scan the german phones on DB
- read all the txt files and store into an array
- check if a blank line
- trim the number
- check if the number starts with +49 or 0049
- check if the number has 11 digits after +49 or 0049
- check if the number already exists

[integration_tests]

- should throw 500 if something goes wrong
- shoul return 400 if the file isn't a txt
- should return 400 if the txt file is empty
- should return 200

[unit_tests]

- `is_blank_line(line: str) -> bool`
  - should return true if is blank line
  - should return false if is not
- `is_german_number(phone_number: str) -> bool`
  - should return false if number doesn't have 11 digits
  - should return false if number not starts with +49 or 0049

OUTPUT: HTTP 200 - body: { task_id: Task ID }

[] TODO: 2. `get_by_task_id(task_id: uuid4) -> Response` Endpoint

Description:
Using the Task ID, a user should be able to retrieve the results of the submitted file

INPUT: {task_id}

- search in database by task ID

OUTPUT: HTTP 200 - body: ["+4915201365263", "004915201365263"]

[integration_tests]

- should return 404 if no record have been found
- should return 200

[] TODO: 3. `delete_task(task_id: uuid4) -> Response` Endpoint

Description:
Using the Task ID, a user should be allowed to delete the results associated to the Task ID 3. Endpoint: Delete results by task ID

INPUT: {task_id}

- delete results by task_id

[integration_tests]

- should return HTTP 404 if no task have been found
- should return HTTP 204

OUTPUT: HTTP 204

[] TODO: 4. `get_all_task_ids() -> Response` Endpoint

Description:
Fetch all Task IDs

- get task IDs by GSI

[integration_tests]

- should return HTTP 404 if no task have been found
- should return 200

OUTPUT: HTTP 200 - body: ["uuid4", "uuid4", "uuid4"]
