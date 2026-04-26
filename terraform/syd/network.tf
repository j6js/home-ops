# Regional Network Config
resource "oci_core_vcn" "syd_vcn" {
    compartment_id  = data.sops_file.oci.data["compartment_ocid"]
    cidr_blocks     = ["10.0.0.0/16"]
	is_ipv6enabled  = true
}
resource "oci_core_internet_gateway" "syd_igw" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  vcn_id         = oci_core_vcn.syd_vcn.id
}
resource "oci_core_subnet" "syd_subnet" {
    compartment_id    = data.sops_file.oci.data["compartment_ocid"]
    vcn_id            = oci_core_vcn.syd_vcn.id
    ipv4cidr_blocks   = ["10.0.1.0/24"]
    ipv6cidr_blocks   = [cidrsubnet(oci_core_vcn.syd_vcn.ipv6cidr_blocks[0], 8, 1)]
    route_table_id    = oci_core_route_table.syd_rt.id
    security_list_ids = [oci_core_security_list.syd_nsl.id]
}
resource "oci_core_security_list" "syd_nsl" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    vcn_id         = oci_core_vcn.syd_vcn.id

    ingress_security_rules {
      protocol    = "all"
      source      = oci_core_vcn.syd_vcn.cidr_block
      source_type = "CIDR_BLOCK"
    }

    ingress_security_rules {
      protocol    = "all"
      source      = oci_core_vcn.syd_vcn.ipv6cidr_blocks[0]
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
resource "oci_core_route_table" "syd_rt" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  vcn_id         = oci_core_vcn.syd_vcn.id
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.syd_igw.id
  }
  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.syd_igw.id
  }
}
resource "oci_core_network_security_group" "syd_nsg" {
	compartment_id = data.sops_file.oci.data["compartment_ocid"]
	vcn_id         = oci_core_vcn.syd_vcn.id
}

# Control Plane 1 IP Config
data "oci_core_vnic" "syd_cp1_vnic" {
  vnic_id = data.oci_core_vnic_attachments.syd_cp1_vnic_attachments.vnic_attachments[0].vnic_id
}
resource "oci_core_public_ip" "syd_cp1_ipv4" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.syd_cp1_privip.private_ips[0].id
}
resource "oci_core_ipv6" "syd_cp1_ipv6" {
    lifetime = "RESERVED"
    subnet_id = oci_core_subnet.syd_subnet.id
    vnic_id = data.oci_core_vnic_attachments.syd_cp1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_private_ips" "syd_cp1_privip" {
  vnic_id = data.oci_core_vnic_attachments.syd_cp1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_vnic_attachments" "syd_cp1_vnic_attachments" {
  compartment_id      = data.sops_file.oci.data["compartment_ocid"]
  instance_id         = oci_core_instance.syd_cp1.id
}

# Worker & Control Plane (sh) 1 IP Config
data "oci_core_vnic" "syd_sh1_vnic" {
  vnic_id = data.oci_core_vnic_attachments.syd_sh1_vnic_attachments.vnic_attachments[0].vnic_id
}
resource "oci_core_public_ip" "syd_sh1_ipv4" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.syd_sh1_privip.private_ips[0].id
}
resource "oci_core_ipv6" "syd_sh1_ipv6" {
    lifetime = "RESERVED"
    subnet_id = oci_core_subnet.syd_subnet.id
    vnic_id = data.oci_core_vnic_attachments.syd_sh1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_private_ips" "syd_sh1_privip" {
  vnic_id = data.oci_core_vnic_attachments.syd_sh1_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_vnic_attachments" "syd_sh1_vnic_attachments" {
  compartment_id      = data.sops_file.oci.data["compartment_ocid"]
  instance_id         = oci_core_instance.syd_sh1.id
}

# Worker & Control Plane (sh) 2 IP Config
data "oci_core_vnic" "syd_sh2_vnic" {
  vnic_id = data.oci_core_vnic_attachments.syd_sh2_vnic_attachments.vnic_attachments[0].vnic_id
}
resource "oci_core_public_ip" "syd_sh2_ipv4" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.syd_sh2_privip.private_ips[0].id
}
resource "oci_core_ipv6" "syd_sh2_ipv6" {
    lifetime = "RESERVED"
    subnet_id = oci_core_subnet.syd_subnet.id
    vnic_id = data.oci_core_vnic_attachments.syd_sh2_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_private_ips" "syd_sh2_privip" {
  vnic_id = data.oci_core_vnic_attachments.syd_sh2_vnic_attachments.vnic_attachments[0].vnic_id
}
data "oci_core_vnic_attachments" "syd_sh2_vnic_attachments" {
  compartment_id      = data.sops_file.oci.data["compartment_ocid"]
  instance_id         = oci_core_instance.syd_sh2.id
}
