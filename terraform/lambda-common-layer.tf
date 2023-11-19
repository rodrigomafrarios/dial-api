resource "null_resource" "deploy_lambda_common_layer_config" {
  triggers = {
    on_every_apply = uuid()
  }

  provisioner "local-exec" {
    command = join(" && ", [
      "rm -f ./common_helpers_layer.zip",
      "rm -rf ./layers",
      "mkdir -p ./layers/python/src/",
      "cp -r ../api/helpers/* ./layers/python/src/",
      "mkdir -p ./layers/python/lib/python3.10/site-packages",
    ])
  }
}

data "archive_file" "common_helpers_layer_code" {
  type        = "zip"
  source_dir  = "./layers"
  output_path = "./common_helpers_layer.zip"
  depends_on  = [null_resource.deploy_lambda_common_layer_config]
}

resource "aws_lambda_layer_version" "common_helpers_layer" {
  layer_name = "${var.env}-common-helpers-layer"

  compatible_architectures = ["arm64"]
  compatible_runtimes      = ["python3.10"]

  s3_bucket         = aws_s3_bucket.common_layers_bucket.bucket
  s3_key            = "${var.env}-common-helpers-layer.zip"
  s3_object_version = aws_s3_object.common_helpers_layer_file.version_id
  source_code_hash  = data.archive_file.common_helpers_layer_code.output_base64sha256
}
