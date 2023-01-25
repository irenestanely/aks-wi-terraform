variable "location" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "cluster_name" {
  default = "k8s"
}

variable "dns_prefix" {
  default = "k8stest1"
}

variable "agent_count" {
  default = 1
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "env" {
  default = "test"
}

variable "user_assigned_identity_id_app1" {
  type = string
}

variable "user_assigned_identity_id_app2" {
  type = string
}


