data "oci_objectstorage_namespace" "syd_objstr_ns" {
	compartment_id = data.sops_file.oci.data["compartment_ocid"]
}
resource "oci_objectstorage_bucket" "syd_objstr_images_bkt" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    name = "j6js-k3s-objstr-bkt-images"
    namespace = data.oci_objectstorage_namespace.syd_objstr_ns.namespace
}
resource "oci_objectstorage_object" "talos_object_arm64" {
	namespace = data.oci_objectstorage_namespace.syd_objstr_ns.namespace
	bucket    = oci_objectstorage_bucket.syd_objstr_images_bkt.name
	object    = "talos-1.12.6-arm64.raw"
	source    = "talos/oracle-arm64.raw"
	content_type = "application/octet-stream"
}
resource "oci_core_image" "talos_image_arm64" {
    compartment_id = data.sops_file.oci.data["compartment_ocid"]
    launch_mode = "PARAVIRTUALIZED"
    
    image_source_details {
        source_type = "objectStorageTuple"
        bucket_name = oci_objectstorage_bucket.syd_objstr_images_bkt.name
        namespace_name = data.oci_objectstorage_namespace.syd_objstr_ns.namespace
        object_name = oci_objectstorage_object.talos_object_arm64.object
    }
    
}
data "oci_core_compute_global_image_capability_schemas" "global" {}

locals {
  global_schema_id = data.oci_core_compute_global_image_capability_schemas.global.compute_global_image_capability_schemas[0].id
}

data "oci_core_compute_global_image_capability_schema" "global_current" {
  compute_global_image_capability_schema_id = local.global_schema_id
}

locals {
  global_schema_version_name = data.oci_core_compute_global_image_capability_schema.global_current.current_version_name
}
resource "oci_core_compute_image_capability_schema" "talos" {
  compartment_id                               = data.sops_file.oci.data["compartment_ocid"]
  image_id                                     = oci_core_image.talos_image_arm64.id
  compute_global_image_capability_schema_version_name = local.global_schema_version_name
  display_name                                 = "talos-arm64-capability-schema"

  schema_data = {
    "Compute.Firmware" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "UEFI_64"
      values         = ["UEFI_64"]
    })

    "Storage.BootVolumeType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })

    "Storage.RemoteDataVolumeType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })

    "Network.AttachmentType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })

    "Storage.LocalDataVolumeType" = jsonencode({
      descriptorType = "enumstring"
      source         = "IMAGE"
      defaultValue   = "PARAVIRTUALIZED"
      values         = ["PARAVIRTUALIZED"]
    })
  }
}

resource "oci_core_shape_management" "talos_a1_flex" {
  compartment_id = data.sops_file.oci.data["compartment_ocid"]
  image_id   = oci_core_image.talos_image_arm64.id
  shape_name = "VM.Standard.A1.Flex"
}