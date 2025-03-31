terraform {
  backend "s3" {
    bucket = "s3-backend-4800"  # Ensure this matches the bucket name you created
    key    = "terraform/statefile.tfstate"
    region = "us-east-2"        # Set this to the region where you created the bucket
  }
}
