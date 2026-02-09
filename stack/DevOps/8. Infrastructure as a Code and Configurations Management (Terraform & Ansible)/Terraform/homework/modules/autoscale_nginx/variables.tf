variable "name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 1
}

variable "user_page_text" {
  type = string
}

variable "target_group_arns" {
  type = list(string)
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
  default     = null
}
