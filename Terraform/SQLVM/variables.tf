variable "location" {
  description = "The Azure location where all resources in this example should be created."
  default = "EastUS"
}

variable "prefix" {
  description = "The prefix used for all resources used by this NetApp Account"
  default = "BGC"
}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}