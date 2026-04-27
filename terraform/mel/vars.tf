variable "syd_tenancy_ocid" {
  description = "The OCID of the SYD tenancy to peer with"
  type        = string
}

variable "syd_administrator_group_ocid" {
  description = "The OCID of the SYD Administrator Group"
  type        = string
}

variable "syd_ipv4_cidr" {
  description = "CIDR block for the Sydney VCN IPv4 range"
  type        = string
}

variable "syd_ipv6_cidr" {
  description = "CIDR block for the Sydney VCN IPv6 range"
  type        = string
}