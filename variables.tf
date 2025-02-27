## Copyright (c) 2023, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.10.0"
    }
  }
  required_version = "= 1.2.9"
}

variable "compartment_ocid" {
  description = "Compartment OCID"
}


# 
variable vcn_id {
  type = string
}

variable  subnet_id {
  type = string
 }


variable vm_display_name {
  type = string
  default = "Thingsboard_instance_docker"
}

variable ssh_public_key {
  type = string
  description = "SSH public key for the instance"
  default = ""
}

variable ad {
  description = "Availability domain"
  type = string
  default = ""
}