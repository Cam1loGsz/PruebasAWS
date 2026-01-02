provider "aws" {
  region = "us-west-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key"
  default_tags {
    tags = {
      Environment = "Development"
      Project     = "PruebasAWS"
    }
  }
}

