resource "libvirt_pool" "os_images" {
  name = "os_images"
  type = "dir"
  path = var.os_images_pool_path
}

resource "libvirt_pool" "volumes" {
  name = "volumes"
  type = "dir"
  path = var.volumes_pool_path
}

