variable "mel_ipv6_cidr" {
  type = string
  description = "CIDR block for Melbourne VCN IPv6 range"
}
variable "mel_ipv4_cidr" {
  type = string
  description = "CIDR block for Melbourne VCN IPv4 range"
}
variable "syd_ipv6_cidr" {
  type = string
  description = "CIDR block for Sydney VCN IPv6 range"
}
variable "syd_ipv4_cidr" {
  type = string
  description = "CIDR block for Sydney VCN IPv4 range"
}
variable "vcn_id" {
  type = string
  description = "OCID of the Sydney VCN"
}
variable "drg_rt_id" {
  type = string
  description = "OCID of the Sydney DRG Route Table"
}
variable "drg_id" {
  type = string
  description = "OCID of the Sydney DRG"
}
variable "rpc_id" {
  type = string
  description = "OCID of the Sydney Remote Peering Connection"
}
variable "nsg_id" {
  type = string
  description = "OCID of the Sydney Network Security Group"
}