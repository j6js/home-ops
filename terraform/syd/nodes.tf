resource "oci_core_instance" "syd_cp1" {
	availability_domain                 = data.oci_identity_availability_domain.syd_ad.name
	compartment_id                      = data.sops_file.oci.data["compartment_ocid"]
	shape                               = "VM.Standard.A1.Flex"
	metadata                            = { "ssh_authorized_keys" : data.sops_file.ssh_authorized_keys.raw }
	display_name                        = "syd-cp1"
	is_pv_encryption_in_transit_enabled = true
	
	create_vnic_details {
		assign_ipv6ip    = false
		assign_public_ip = false
		nsg_ids          = [oci_core_network_security_group.syd_nsg.id]
		subnet_id        = oci_core_subnet.syd_subnet.id
	}
	launch_options {
		firmware = "UEFI_64"
		is_pv_encryption_in_transit_enabled = true
		network_type = "PARAVIRTUALIZED"
	}
	shape_config {
		memory_in_gbs = 8
		ocpus = 1
	}
	source_details {
		source_id = oci_core_image.talos_image_arm64.id
		source_type = "image"
		boot_volume_size_in_gbs = "65"
	}
}
resource "oci_core_instance" "syd_sh1" {
	availability_domain                 = data.oci_identity_availability_domain.syd_ad.name
	compartment_id                      = data.sops_file.oci.data["compartment_ocid"]
	shape                               = "VM.Standard.A1.Flex"
	metadata                            = { "ssh_authorized_keys" : data.sops_file.ssh_authorized_keys.raw }
	display_name                        = "syd-sh1"
	is_pv_encryption_in_transit_enabled = true
	
	create_vnic_details {
		assign_ipv6ip    = false
		assign_public_ip = false
		nsg_ids          = [oci_core_network_security_group.syd_nsg.id]
		subnet_id        = oci_core_subnet.syd_subnet.id
	}
	launch_options {
		firmware = "UEFI_64"
		is_pv_encryption_in_transit_enabled = true
		network_type = "PARAVIRTUALIZED"
	}
	shape_config {
		memory_in_gbs = 8
		ocpus = 1
	}
	source_details {
		source_id = oci_core_image.talos_image_arm64.id
		source_type = "image"
		boot_volume_size_in_gbs = "65"
	}
}
resource "oci_core_instance" "syd_sh2" {
	availability_domain                 = data.oci_identity_availability_domain.syd_ad.name
	compartment_id                      = data.sops_file.oci.data["compartment_ocid"]
	shape                               = "VM.Standard.A1.Flex"
	metadata                            = { "ssh_authorized_keys" : data.sops_file.ssh_authorized_keys.raw }
	display_name                        = "syd-sh2"
	is_pv_encryption_in_transit_enabled = true
	
	create_vnic_details {
		assign_ipv6ip    = false
		assign_public_ip = false
		nsg_ids          = [oci_core_network_security_group.syd_nsg.id]
		subnet_id        = oci_core_subnet.syd_subnet.id
	}
	launch_options {
		firmware = "UEFI_64"
		is_pv_encryption_in_transit_enabled = true
		network_type = "PARAVIRTUALIZED"
	}
	shape_config {
		memory_in_gbs = 8
		ocpus = 1
	}
	source_details {
		source_id = oci_core_image.talos_image_arm64.id
		source_type = "image"
		boot_volume_size_in_gbs = "65"
	}
}