resource "libvirt_pool" "os_images" {
  name = "os_images"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-os_image"
}

resource "libvirt_pool" "volumes" {
  name = "volumes"
  type = "dir"
  path = "/images"
}

resource "libvirt_volume" "os_image" {
  name   = "ubuntu-qcow2"
  pool   = libvirt_pool.os_images.name
  source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  format = "qcow2"
}

resource "libvirt_volume" "vm" {
  name           = "baas-test"
  pool           = libvirt_pool.volumes.name
  base_volume_id = libvirt_volume.os_image.id
  format         = "qcow2" 
}

data "template_file" "user_data" {
  template = file("cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.os_images.name
}

resource "libvirt_domain" "vm" {
  name   = "baas-test"
  memory = "512"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.vm.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}
