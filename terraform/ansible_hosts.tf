data "template_file" "ansible_hosts" {
  template = file("ansible_hosts.tpl")
  vars = {
    baas_ip = join("\n", libvirt_domain.vm.*.network_interface.0.addresses.0)
  }
}

resource "local_file" "ansible_hosts" {
  content         = data.template_file.ansible_hosts.rendered
  filename        = "../ansible/hosts"
  file_permission = "0644"
}

