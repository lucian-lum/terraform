provider "aws" {
    region = var.region
}

provider "awscc" {
    region = var.region
}


#resource "awscc_sagemaker_pipeline" "sm" {
#  pipeline_definition = {
#      pipeline_definition_s3_location = {
#              bucket = "lumlucia-abalone-us-west-2"
#              key = "json/abalone_json.json"
#          }
#    }
#  pipeline_name = "terraform-pipeline-orange"
#  role_arn = "arn:aws:iam::305354778947:role/service-role/AmazonSageMaker-ExecutionRole-20221217T190462"
#}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "lumlucia-terraform-state-us-west-2"
    lifecycle {
      prevent_destroy = true
    }
}

resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id
      versioning_configuration {
        status = "Enabled"
        }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-db-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
    name = "LockID"
    type = "S"
    }
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}