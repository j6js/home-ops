terraform {
	required_providers {
		oci = {
			source = "oracle/oci"
			configuration_aliases = [ oci ]
		}
		sops = {
		  source  = "carlpett/sops"
		  version = "1.4.1"
		}
	}
}

data "sops_file" "oci" {
	source_file = ".secrets/oracle-syd.yaml"
}
