# Variables
# Some sensitive information
 variable "v-access-key" {}
 variable "v-secret-key" {}
 variable "region" {}

# Shareable information
variable "v-ami-image" {
    description = "Ubuntu Server 22.04 LTS (HVM), SSD Volume Type"
    default = "ami-0ec7f9846da6b0f61"
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
