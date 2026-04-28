terraform {
	required_providers {
		oci = {
			source = "oracle/oci"
			configuration_aliases = [ oci ]
		}
		sops = {
		  source  = "carlpett/sops"
		  version = "1.4.1"
		}
	}
}
resource "oci_identity_policy" "request_rpc_to_mel" {
  name           = "request-rpc-to-mel"
  description    = "Allow peering to MEL tenancy"
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  statements = [
    "Define tenancy Acceptor as ${var.mel_tenancy_ocid}",
    "Allow group id ${var.syd_administrator_group_ocid} to manage remote-peering-from in compartment id ${data.sops_file.oci.data["compartment_ocid"]}",
    "Endorse group id ${var.syd_administrator_group_ocid} to manage remote-peering-to in tenancy Acceptor"
  ]
}

data "sops_file" "oci" {
	source_file = ".secrets/oracle-syd.yaml"
}
data "sops_file" "oci_mel" {
	source_file = ".secrets/oracle-mel.yaml"
}

data "sops_file" "ssh_authorized_keys" {
	source_file = ".secrets/authorized_keys"
    input_type = "raw"
}

data "oci_identity_availability_domain" "syd_ad" {
	compartment_id = data.sops_file.oci.data["compartment_ocid"]
	ad_number = 1
}

# To be passed to other modules
output "vcn_cidr_block" {
  value = oci_core_vcn.syd_vcn.cidr_block
}
output "vcn_ipv6_cidr_block" {
  value = oci_core_vcn.syd_vcn.ipv6cidr_blocks[0]
}
output "vcn_id" {
  value = oci_core_vcn.syd_vcn.id
}
output "rpc_id" {
  value = oci_core_remote_peering_connection.syd_to_mel_rpc.id
}
output "drg_id" {
  value = oci_core_drg.syd_drg.id
}
output "drg_rt_id" {
  value = oci_core_drg_route_table.syd_drg_rt.id
}
output "nsg_id" {
  value = oci_core_network_security_group.syd_nsg.id
}

# To be passed to talhelper and co
output "nodes" {
  value = {
    syd_cp1 = {
      private_ipv4 = oci_core_instance.syd_cp1.private_ip
      public_ipv4  = oci_core_public_ip.syd_cp1_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_cp1_ipv6.ip_address
      role         = "control_plane"
    }
    syd_sh1 = {
      private_ipv4 = oci_core_instance.syd_sh1.private_ip
      public_ipv4  = oci_core_public_ip.syd_sh1_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_sh1_ipv6.ip_address 
      role         = "shared"
    }
    syd_sh2 = {
      private_ipv4 = oci_core_instance.syd_sh2.private_ip
      public_ipv4  = oci_core_public_ip.syd_sh2_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_sh2_ipv6.ip_address
      role       = "shared"
    }
  }
}
