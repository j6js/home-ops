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
resource "oci_core_remote_peering_connection" "syd_to_mel_rpc" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = oci_core_drg.syd_drg.id
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
}

resource "oci_core_drg_route_table_route_rule" "syd_local_ipv6" {
    drg_route_table_id         = oci_core_drg_route_table.syd_drg_rt.id
    destination                = oci_core_vcn.syd_vcn.ipv6cidr_blocks[0]
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment.syd_drg_attachment.id
}

