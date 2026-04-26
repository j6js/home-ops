### --- Rules for NSG ---

## Rules to allow traffic between Melbourne nodes in the same NSG
resource "oci_core_network_security_group_security_rule" "mel_nodes_from_mel_nodes" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "all"
    source                    = var.nsg_id
    source_type               = "NETWORK_SECURITY_GROUP"
}

resource "oci_core_network_security_group_security_rule" "mel_nodes_to_mel_nodes" {
    network_security_group_id = var.nsg_id
    direction                 = "EGRESS"
    protocol                  = "all"
    destination               = var.nsg_id
    destination_type          = "NETWORK_SECURITY_GROUP"
}

## Rules to allow traffic from Sydney VCN to Melbourne VCN
resource "oci_core_network_security_group_security_rule" "mel_from_syd-ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "all"
    source                    = var.syd_ipv4_cidr
    source_type               = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "mel_from_syd-ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "all"
    source                    = var.syd_ipv6_cidr
    source_type               = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "mel_to_syd-ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "EGRESS"
    protocol                  = "all"
    destination               = var.syd_ipv4_cidr
    destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "mel_to_syd-ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "EGRESS"
    protocol                  = "all"
    destination               = var.syd_ipv6_cidr
    destination_type          = "CIDR_BLOCK"
}

## Rules to allow traffic from Melbourne VCN to Internet
resource "oci_core_network_security_group_security_rule" "mel_nsg_to_internet_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "EGRESS"
    protocol                  = "all"
    destination               = "0.0.0.0/0"
    destination_type          = "CIDR_BLOCK"
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_to_internet_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "EGRESS"
    protocol                  = "all"
    destination               = "::/0"
    destination_type          = "CIDR_BLOCK"
}
## Rules to allow traffic from Internet to Melbourne VCN
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_http_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 80
            max = 80
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_http_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "::/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 80
            max = 80
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_https_tcp_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 443
            max = 443
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_https_tcp_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "::/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 443
            max = 443
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_https_udp_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "17"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    udp_options {
        destination_port_range {
            min = 443
            max = 443
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_https_udp_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "17"
    source                    = "::/0"
    source_type               = "CIDR_BLOCK"
    udp_options {
        destination_port_range {
            min = 443
            max = 443
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_icmp_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "1"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_icmp_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "1"
    source                    = "::/0"
    source_type               = "CIDR_BLOCK"
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_talosapi_ipv4" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "0.0.0.0/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 50000
            max = 50000
        }
    }
}
resource "oci_core_network_security_group_security_rule" "mel_nsg_from_internet_talosapi_ipv6" {
    network_security_group_id = var.nsg_id
    direction                 = "INGRESS"
    protocol                  = "6"
    source                    = "::/0"
    source_type               = "CIDR_BLOCK"
    tcp_options {
        destination_port_range {
            min = 50000
            max = 50000
        }
    }
}