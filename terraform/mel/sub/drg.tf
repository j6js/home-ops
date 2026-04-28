data "oci_core_drg_attachments" "mel_to_syd_attachments" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = var.drg_id
    attachment_type = "REMOTE_PEERING_CONNECTION"
    network_id     = var.rpc_id
}
# Melbourne DRG routes
resource "oci_core_drg_route_table_route_rule" "mel-local-ipv4" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.mel_ipv4_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.mel_to_syd_attachments.drg_attachments[0].id
}
resource "oci_core_drg_route_table_route_rule" "mel-local-ipv6" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.mel_ipv6_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.mel_to_syd_attachments.drg_attachments[0].id
}
resource "oci_core_drg_route_table_route_rule" "mel-remote-ipv4" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.syd_ipv4_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.mel_to_syd_attachments.drg_attachments[0].id
}

resource "oci_core_drg_route_table_route_rule" "mel-remote-ipv6" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.syd_ipv6_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.mel_to_syd_attachments.drg_attachments[0].id
}
