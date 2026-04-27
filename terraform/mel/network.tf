# Regional Network Config
resource "oci_core_vcn" "mel_vcn" {
    compartment_id  = data.sops_file.oci.data["compartment_ocid"]
    cidr_blocks     = ["10.1.0.0/16"]
	is_ipv6enabled  = true
}
resource "oci_core_internet_gateway" "mel_igw" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  vcn_id         = oci_core_vcn.mel_vcn.id
}
resource "oci_core_subnet" "mel_subnet" {
    compartment_id    = data.sops_file.oci.data["compartment_ocid"]
    vcn_id            = oci_core_vcn.mel_vcn.id
    ipv4cidr_blocks   = ["10.1.1.0/24"]
    ipv6cidr_blocks   = [cidrsubnet(oci_core_vcn.mel_vcn.ipv6cidr_blocks[0], 8, 1)]
    route_table_id    = oci_core_route_table.mel_rt.id
    security_list_ids = [oci_core_security_list.mel_nsl.id]
}
resource "oci_core_security_list" "mel_nsl" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    vcn_id         = oci_core_vcn.mel_vcn.id

    ingress_security_rules {
      protocol    = "all"
      source      = oci_core_vcn.mel_vcn.cidr_block
      source_type = "CIDR_BLOCK"
    }

    ingress_security_rules {
      protocol    = "all"
      source      = oci_core_vcn.mel_vcn.ipv6cidr_blocks[0]
      source_type = "CIDR_BLOCK"
    }

    ingress_security_rules {
      protocol    = "all"
      source      = var.syd_ipv4_cidr
      source_type = "CIDR_BLOCK"
    }

    ingress_security_rules {
      protocol    = "all"
      source      = var.syd_ipv6_cidr
      source_type = "CIDR_BLOCK"
    }

    egress_security_rules {
      protocol         = "all"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
    }

    egress_security_rules {
      protocol         = "all"
      destination      = "::/0"
      destination_type = "CIDR_BLOCK"
    }
}
resource "oci_core_route_table" "mel_rt" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  vcn_id         = oci_core_vcn.mel_vcn.id
  
  route_rules {
    destination       = var.syd_ipv4_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.mel_drg.id
  }
  route_rules {
    destination       = var.syd_ipv6_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.mel_drg.id
  }
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mel_igw.id
  }
  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.mel_igw.id
  }
}
resource "oci_core_network_security_group" "mel_nsg" {
	compartment_id = data.sops_file.oci.data["compartment_ocid"]
	vcn_id         = oci_core_vcn.mel_vcn.id
}

# Worker 1 IP Config
data "oci_core_vnic" "mel_wk1_vnic" {
  vnic_id = data.oci_core_vnic_attachments.mel_wk1_vnic_attachments.vnic_attachments[0].vnic_id
}
resource "oci_core_public_ip" "mel_wk1_ipv4" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.mel_wk1_privip.private_ips[0].id
}
resource "oci_core_ipv6" "mel_wk1_ipv6" {
    lifetime = "RESERVED"
    subnet_id = oci_core_subnet.mel_subnet.id
    vnic_id = data.oci_core_vnic_attachments.mel_wk1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_private_ips" "mel_wk1_privip" {
  vnic_id = data.oci_core_vnic_attachments.mel_wk1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_vnic_attachments" "mel_wk1_vnic_attachments" {
  compartment_id      = data.sops_file.oci.data["compartment_ocid"]
  instance_id         = oci_core_instance.mel_wk1.id
}

# Worker 2 IP Config
data "oci_core_vnic" "mel_wk2_vnic" {
  vnic_id = data.oci_core_vnic_attachments.mel_wk2_vnic_attachments.vnic_attachments[0].vnic_id
}
resource "oci_core_public_ip" "mel_wk2_ipv4" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.mel_wk2_privip.private_ips[0].id
}
resource "oci_core_ipv6" "mel_wk2_ipv6" {
    lifetime = "RESERVED"
    subnet_id = oci_core_subnet.mel_subnet.id
    vnic_id = data.oci_core_vnic_attachments.mel_wk2_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_private_ips" "mel_wk2_privip" {
  vnic_id = data.oci_core_vnic_attachments.mel_wk2_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_vnic_attachments" "mel_wk2_vnic_attachments" {
  compartment_id      = data.sops_file.oci.data["compartment_ocid"]
  instance_id         = oci_core_instance.mel_wk2.id
}
