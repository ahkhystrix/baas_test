resource "libvirt_volume" "os_image" {
  name   = var.project["vm_os"]
  pool   = libvirt_pool.os_images.name
  source = var.os_images[var.project.vm_os]
  format = "qcow2"
}

resource "libvirt_volume" "vm" {
  count          = var.project["vm_count"]

  name           = format("%s%d", var.project["vm_name"], count.index + 1)
  pool           = libvirt_pool.volumes.name
  base_volume_id = libvirt_volume.os_image.id
  format         = "qcow2"
}

