variable "project" {
  description = "The project"
  type        = map
  default     = {
    vm_name   = "baas_test"
    vm_vcpu   = 1
    vm_memory = "256"
    vm_os     = "ubuntu16_04"
    vm_count  = 2
  }
}

variable "default_ssh_authorized_key" {
  description = "The libvirt uri"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "libvirt_uri" {
  description = "The libvirt uri"
  type        = string
  default     = "qemu:///system"
}

variable "os_images_pool_path" {
  description = "The os images pool path"
  type        = string
  default     = "/kvm/os_images"
}

variable "volumes_pool_path" {
  description = "The volumes pool path"
  type        = string
  default     = "/kvm/volumes"
}

variable "os_images" {
  description = "The os images"
  type        = map
  default     = {
    ubuntu16_04 = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img" 
  }
}
