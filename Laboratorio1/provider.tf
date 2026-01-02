provider "aws" {
  region = "us-west-1"
  default_tags {
    tags = {
      Environment = "Development"
      Project     = "PruebasAWS"
    }
  }
}

