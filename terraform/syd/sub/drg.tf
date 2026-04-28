data "oci_core_drg_attachments" "syd_to_mel_attachments" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    drg_id         = var.drg_id
    attachment_type = "REMOTE_PEERING_CONNECTION"
    network_id     = var.rpc_id
}

resource "oci_core_drg_route_table_route_rule" "syd-local-ipv4" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.syd_ipv4_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.syd_to_mel_attachments.drg_attachments[0].id
}
resource "oci_core_drg_route_table_route_rule" "syd-local-ipv6" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.syd_ipv6_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.syd_to_mel_attachments.drg_attachments[0].id
}
resource "oci_core_drg_route_table_route_rule" "syd-remote-ipv4" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.mel_ipv4_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.syd_to_mel_attachments.drg_attachments[0].id
}
resource "oci_core_drg_route_table_route_rule" "syd-remote-ipv6" {
    drg_route_table_id         = var.drg_rt_id
    destination                = var.mel_ipv6_cidr
    destination_type           = "CIDR_BLOCK"
    next_hop_drg_attachment_id = data.oci_core_drg_attachments.syd_to_mel_attachments.drg_attachments[0].id
}