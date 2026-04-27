resource "oci_core_drg" "syd_drg" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
}
resource "oci_core_drg_route_table" "syd_drg_rt" {
    drg_id         = oci_core_drg.syd_drg.id
}
resource "oci_core_drg_attachment" "syd_drg_attachment" {
    drg_id           = oci_core_drg.syd_drg.id
    vcn_id           = oci_core_vcn.syd_vcn.id
    drg_route_table_id = oci_core_drg_route_table.syd_drg_rt.id
}

resource "null_resource" "wait_for_syd_attachment" {
  depends_on = [oci_core_drg_attachment.syd_drg_attachment]
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "null_resource" "wait_for_iam" {
  depends_on = [oci_identity_policy.request_rpc_to_mel]
  provisioner "local-exec" {
    command = "sleep 30"
  }
}

resource "oci_core_remote_peering_connection" "syd_to_mel_rpc" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = oci_core_drg.syd_drg.id
    peer_id = var.mel_rpc_id
    peer_region_name = data.sops_file.oci_mel.data["region"]
    depends_on = [null_resource.wait_for_iam]
}
data "oci_core_drg_attachments" "syd_to_mel_attachments" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = oci_core_drg.syd_drg.id
    attachment_type = "REMOTE_PEERING_CONNECTION"
    network_id     = oci_core_remote_peering_connection.syd_to_mel_rpc.id
}

# Sydney DRG routes
resource "oci_core_drg_route_table_route_rule" "syd_local_pv4" {
    drg_route_table_id         = oci_core_drg_route_table.syd_drg_rt.id
    destination                = oci_core_vcn.syd_vcn.cidr_block
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment.syd_drg_attachment.id
    depends_on = [null_resource.wait_for_syd_attachment]
}

resource "oci_core_drg_route_table_route_rule" "syd_local_ipv6" {
    drg_route_table_id         = oci_core_drg_route_table.syd_drg_rt.id
    destination                = oci_core_vcn.syd_vcn.ipv6cidr_blocks[0]
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment.syd_drg_attachment.id
    depends_on = [null_resource.wait_for_syd_attachment]
}

