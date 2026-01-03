terraform {
  backend "s3" {
    bucket = "tfstate-s3-bucket"              # Nombre del bucket donde se guardará el state
    key    = "laboratorio1/terraform.tfstate" # Ruta/nombre del archivo state dentro del bucket
    region = "us-east-1"                      # Región del bucket
    encrypt = true                           
  }
}