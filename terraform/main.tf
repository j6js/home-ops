terraform {
	required_providers {
		oci = {
			source = "oracle/oci"
			version = "8.1.0"
		}
		sops = {
		  source  = "carlpett/sops"
		  version = "1.4.1"
		}
	}
}

provider sops {}

data "sops_file" "oci_syd" {
	source_file = ".secrets/oracle-syd.yaml"
}
data "sops_file" "oci_mel" {
	source_file = ".secrets/oracle-mel.yaml"
}

provider oci {
	alias = "syd"
	tenancy_ocid = data.sops_file.oci_syd.data["tenancy_ocid"]
	user_ocid = data.sops_file.oci_syd.data["user_ocid"]
	private_key = data.sops_file.oci_syd.data["private_key"]
	fingerprint = data.sops_file.oci_syd.data["fingerprint"]
	region = data.sops_file.oci_syd.data["region"]
}
provider oci {
	alias = "mel"
	tenancy_ocid = data.sops_file.oci_mel.data["tenancy_ocid"]
	user_ocid = data.sops_file.oci_mel.data["user_ocid"]
	private_key = data.sops_file.oci_mel.data["private_key"]
	fingerprint = data.sops_file.oci_mel.data["fingerprint"]
	region = data.sops_file.oci_mel.data["region"]
}

module "mel" {
  source = "./mel"
  syd_tenancy_ocid = data.sops_file.oci_syd.data["tenancy_ocid"]
  providers = {
    oci = oci.mel
  }
}
module "syd" {
  source = "./syd"
  mel_rpc_id = module.mel.rpc_id
  mel_tenancy_ocid = data.sops_file.oci_mel.data["tenancy_ocid"]
  mel_administrator_group_ocid = data.sops_file.oci_mel.data["admininstrator_group_ocid"]
  providers = {
    oci = oci.syd
  }
}

module "mel_sub" {
  source = "./mel/sub"
  vcn_id = module.mel.vcn_id
  syd_ipv4_cidr = module.syd.vcn_cidr_block
  syd_ipv6_cidr = module.syd.vcn_ipv6_cidr_block
  rpc_id = module.mel.rpc_id
  drg_id = module.mel.drg_id
  drg_rt_id = module.mel.drg_rt_id
  nsg_id = module.mel.nsg_id
  providers = {
	oci = oci.mel
  }	
}

module "syd_sub" {
  source = "./syd/sub"
  vcn_id = module.syd.vcn_id
  mel_ipv4_cidr = module.mel.vcn_cidr_block
  mel_ipv6_cidr = module.mel.vcn_ipv6_cidr_block
  rpc_id = module.syd.rpc_id
  drg_id = module.syd.drg_id
  drg_rt_id = module.syd.drg_rt_id
  nsg_id = module.syd.nsg_id
  providers = {
	oci = oci.syd
  }
}

output "nodes" {
  value = merge(module.syd.nodes, module.mel.nodes)
}
output "nlb_private_ip" {
  value = module.syd.cp_nlb_ip
}
resource "local_file" "talconfig" {
  filename = "../talos/talconfig.yaml"
  content  = templatefile("${path.module}/talconfig.yaml.tftpl", {
    cluster_name     = "j6js-k8s"
    kube_vip_ip      = module.syd.cp_nlb_ip
    nodes = merge(module.syd.nodes, module.mel.nodes)
  })
}
