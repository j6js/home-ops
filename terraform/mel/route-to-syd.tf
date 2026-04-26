resource "oci_core_drg" "mel_drg" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
}
resource "oci_core_drg_route_table" "mel_drg_rt" {
    drg_id         = oci_core_drg.mel_drg.id
}
resource "oci_core_drg_attachment" "mel_drg_attachment" {
    drg_id           = oci_core_drg.mel_drg.id
    vcn_id           = oci_core_vcn.mel_vcn.id
    drg_route_table_id = oci_core_drg_route_table.mel_drg_rt.id
}
resource "oci_core_remote_peering_connection" "mel_to_syd_rpc" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = oci_core_drg.mel_drg.id
}
data "oci_core_drg_attachments" "mel_to_syd_attachments" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = oci_core_drg.mel_drg.id
    attachment_type = "REMOTE_PEERING_CONNECTION"
    network_id     = oci_core_remote_peering_connection.mel_to_syd_rpc.id
}

# Melbourne DRG routes
resource "oci_core_drg_route_table_route_rule" "mel-local-ipv6" {
    drg_route_table_id         = oci_core_drg_route_table.mel_drg_rt.id
    destination                = oci_core_vcn.mel_vcn.ipv6cidr_blocks[0]
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = oci_core_drg_attachment.mel_drg_attachment.id
}

