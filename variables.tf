variable "key_name" {
  description = "Nombre de la key pair para la instancia EC2"
  type        = string
  default     = "fran-key"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}
