terraform {
  backend "s3" {
    bucket         = "isi-final-iti-project-rstate-2"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table-isi-2"
  }
}
