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

resource "oci_identity_policy" "request_rpc_to_syd" {
  name           = "request-rpc-to-syd"
  description    = "Allow peering to SYD tenancy"
  compartment_id = data.sops_file.oci.data["tenancy_ocid"]

  statements = [
    "Define tenancy SydTenancy as ${var.syd_tenancy_ocid}",
    "Endorse group Administrators to manage remote-peering-to in tenancy SydTenancy"
  ]
}
data "sops_file" "oci" {
	source_file = ".secrets/oracle-mel.yaml"
}

data "sops_file" "ssh_authorized_keys" {
	source_file = ".secrets/authorized_keys"
    input_type = "raw"
}

data "oci_identity_availability_domain" "mel_ad" {
	compartment_id = data.sops_file.oci.data["compartment_ocid"]
	ad_number = 1
}

# To be passed to other modules
output "vcn_cidr_block" {
  value = oci_core_vcn.mel_vcn.cidr_block
}
output "vcn_ipv6_cidr_block" {
  value = oci_core_vcn.mel_vcn.ipv6cidr_blocks[0]
}
output "vcn_id" {
  value = oci_core_vcn.mel_vcn.id
}
output "rpc_id" {
  value = oci_core_remote_peering_connection.mel_to_syd_rpc.id
}
output "drg_id" {
  value = oci_core_drg.mel_drg.id
}
output "drg_rt_id" {
  value = oci_core_drg_route_table.mel_drg_rt.id
}
output "nsg_id" {
  value = oci_core_network_security_group.mel_nsg.id
}

# To be passed to talhelper and co
output "nodes" {
  value = {
    mel_wk1 = {
      private_ipv4 = oci_core_instance.mel_wk1.private_ip
      public_ipv4  = oci_core_public_ip.mel_wk1_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.mel_wk1_ipv6.ip_address
      role         = "worker"
    }
    mel_wk2 = {
      private_ipv4 = oci_core_instance.mel_wk2.private_ip
      public_ipv4  = oci_core_public_ip.mel_wk2_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.mel_wk2_ipv6.ip_address 
      role         = "worker"
    }
  }
}
