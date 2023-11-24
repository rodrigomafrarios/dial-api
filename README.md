[x] TODO: Terraform Infrastructure

- API Gateway [x]
- Proxy lambda {proxy+} [x]
- dynamodb table [x]
- IAM Roles [x]
- IAM Permissions [x]

Output: Api gateway endpoint

[x] TODO: Data Model

`TaskModel(BaseModel):`

- task_id: uuid4 (GSI)
- phone_number: str (PK)

# APIS

Setup lambda powertools

- [x] Data validation
- [x] Error handling

[x] TODO: 1. `create_task() -> Response` Endpoint

Description:
Submit a file to the endpoint to be processed

INPUT: Submit a file to the endpoint to be processed. Example files are provided, see phone_numbers_1.txt phone_numbers_2.txt phone_numbers_3.txt

- scan the german phones on DB [x]
- read all the txt files and store into an array [x]
- check if a blank line [x]
- trim the number [x]
- check if the number starts with +49 or 0049 [x]
- check if the number has 11 digits after +49 or 0049 [x]
- check if the number already exists [x]

[integration_tests]

- should return 400 if no germana phone number found
- should return 200

OUTPUT: HTTP 200 - body: { task_id: Task ID }

[x] TODO: 2. `get_by_task_id(task_id: uuid4) -> Response` Endpoint

Description:
Using the Task ID, a user should be able to retrieve the results of the submitted file

INPUT: {task_id}

- search in database by task ID

OUTPUT: HTTP 200 - body: ["+4915201365263", "004915201365263"]

[integration_tests]

- should throw 500 if something goes wrong
- should return 200

[x] TODO: 3. `delete_task(task_id: uuid4) -> Response` Endpoint

Description:
Using the Task ID, a user should be allowed to delete the results associated to the Task ID 3. Endpoint: Delete results by task ID

INPUT: {task_id}

- delete results by task_id

[integration_tests]

- should throw 500 if something goes wrong
- should return HTTP 204

OUTPUT: HTTP 204

[x] TODO: 4. `get_all_task_ids() -> Response` Endpoint

Description:
Fetch all Task IDs

- get task IDs by GSI

[integration_tests]

- should throw 500 if something goes wrong
- should return 200

OUTPUT: HTTP 200 - body: ["uuid4", "uuid4", "uuid4"]

# Deploy

[dev]

1. Create tf state bucket with the name: `dev-german-phone-parser-tf-backend`
2. terraform init -backend-config=envs/dev/backend.dev.conf
3. terraform plan -var-file=envs/dev/variables.dev.tfvars
4. AWS_PROFILE=YOUR_PROFILE terraform apply -var-file=envs/dev/backend.dev.tfvars

The output `apigw_url` is the API Gateway Default Endpoint

- Example URL: `https://apiId.execute-api.eu-central-1.amazonaws.com/dev`

# Swagger docs

- It's possible to check the API documentation calling the route `/api-docs/index.html`
- Example URL: `https://apiId.execute-api.eu-central-1.amazonaws.com/dev/api-docs/index.html`
