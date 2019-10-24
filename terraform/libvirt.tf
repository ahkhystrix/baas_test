data "template_file" "user_data" {
  count = var.project["vm_count"]

  template = file("libvirt_cloud_init.cfg")
  vars = {
    ssh_authorized_key = file(var.default_ssh_authorized_key)
  }
}

data "template_file" "network_config" {
  template = file("libvirt_network.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.project["vm_count"]

  name           = format("commoninit-%s%d.iso",
                     var.project["vm_name"], count.index)
  user_data      = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.os_images.name
}

resource "libvirt_domain" "vm" {
  count  = var.project["vm_count"]

  name   = format("%s%d", var.project["vm_name"], count.index + 1)
  vcpu   = var.project["vm_vcpu"]
  memory = var.project["vm_memory"]

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

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
    volume_id = libvirt_volume.vm[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  provisioner "local-exec" {
    command = <<EOT
      iptables -t nat -I PREROUTING \
      -p tcp --dport ${ 2201 + count.index } -j DNAT \
      --to ${ self.network_interface.0.addresses.0 }:22
      iptables -t nat -I PREROUTING \
      -p tcp --dport ${ 5901 + count.index } -j DNAT \
      --to ${ self.network_interface.0.addresses.0 }:5901
      iptables -t nat -I PREROUTING \
      -p tcp --dport ${ 6901 + count.index } -j DNAT \
      --to ${ self.network_interface.0.addresses.0 }:6901
      iptables -I FORWARD -i virbr0 \
      -d ${ self.network_interface.0.addresses.0 } -j ACCEPT
  EOT
  }

}
