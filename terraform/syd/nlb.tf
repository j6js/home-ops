locals {
  backend = {
    syd_cp1 = {
      private_ipv4 = oci_core_instance.syd_cp1.private_ip
      public_ipv4  = oci_core_public_ip.syd_cp1_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_cp1_ipv6.ip_address
      role         = "control_plane"
    }
    syd_sh1 = {
      private_ipv4 = oci_core_instance.syd_sh1.private_ip
      public_ipv4  = oci_core_public_ip.syd_sh1_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_sh1_ipv6.ip_address 
      role         = "shared"
    }
    syd_sh2 = {
      private_ipv4 = oci_core_instance.syd_sh2.private_ip
      public_ipv4  = oci_core_public_ip.syd_sh2_ipv4.ip_address
      public_ipv6  = oci_core_ipv6.syd_sh2_ipv6.ip_address
      role       = "shared"
    }
  }
}
resource "oci_network_load_balancer_network_load_balancer" "cp_nlb" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  display_name   = "control-plane-nlb"
  subnet_id      = oci_core_subnet.syd_subnet.id
  is_private     = true    # internal only, no public IP needed
}

resource "oci_network_load_balancer_backend_set" "cp_backend" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.cp_nlb.id
  name                     = "control-plane-backends"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol = "TCP"
    port     = 6443
  }
}

resource "oci_network_load_balancer_backend" "cp_nodes" {
  for_each = {
    for name, node in local.backend :
    name => node if contains(["control_plane", "shared"], node.role)
  }

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.cp_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.cp_backend.name
  name                     = each.key
  ip_address               = each.value.private_ipv4
  port                     = 6443
}

resource "oci_network_load_balancer_listener" "cp_listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.cp_nlb.id
  name                     = "cp-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.cp_backend.name
  port                     = 6443
  protocol                 = "TCP"
}

output "cp_nlb_ip" {
  value = oci_network_load_balancer_network_load_balancer.cp_nlb.ip_addresses[0].ip_address
}