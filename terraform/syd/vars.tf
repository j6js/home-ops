variable "mel_rpc_id" {
  type = string
  description = "OCID of the Melbourne Remote Peering Connection"
}

variable "mel_ipv4_cidr" {
  description = "CIDR block for the Melbourne VCN IPv4 range"
  type        = string
}

variable "mel_ipv6_cidr" {
  description = "CIDR block for the Melbourne VCN IPv6 range"
  type        = string
}

variable "mel_tenancy_ocid" {
  type = string
  description = "OCID of the Melbourne Tenancy"
}

variable "syd_administrator_group_ocid" {
  type = string
  description = "OCID of the Sydney Administrator Group"
}