# Variables
# Some sensitive information
variable "v-access-key" {
   description = "AWS Access Key"
   type        = string
   default     = "YOUR_ACCESS_KEY"
}
 variable "v-secret-key" {
   description = "AWS Secret Key"
   type        = string
   default     = "YOUR_SECRET_KEY"
}
variable "region" {
   description = "AWS Reagon"
   default     = "eu-central-1"
}

# Shareable information
variable "v-ami-image" {
    description = "Ubuntu Server 22.04 LTS (HVM), SSD Volume Type"
    default = "ami-04e601abe3e1a910f"
}
variable "v-instance-type" {
    description = "EC2 instance type"
    default = "t2.micro"
}
variable "v-instance-key" {
    description = "Instance key"
    default = "terraform-key2"
}

# variable "v_vsgi" {}
# variable "v_si" {}
