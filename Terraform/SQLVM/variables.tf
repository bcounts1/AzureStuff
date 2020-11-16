variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "location" {
  description = "The Azure location where all resources in this example should be created."
  default = "EastUS"
}

variable "prefix" {
  description = "The prefix used for resources"
}
variable "osusername"{}
variable "ospassword"{}
variable "sqlusername"{}
variable "sqlpassword"{}