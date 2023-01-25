terraform {
    backend "s3" {
    bucket = "lumlucia-terraform-state-us-west-2"
    key = "global/s3/terraform.tfstate"
    region = "us-west-2"
    
    dynamodb_table = "terraform-db-locks"
    encrypt = true
    }
}