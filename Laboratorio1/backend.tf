terraform {
  backend "s3" {
    bucket = module.s3_bucket.bucket          # Nombre del bucket donde se guardará el state
    key    = "laboratorio1/terraform.tfstate" # Ruta/nombre del archivo state dentro del bucket
    region = "us-east-1"                      # Región del bucket
    encrypt = true                            # Encriptar el state en S3
  }
}