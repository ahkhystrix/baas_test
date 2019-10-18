resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    command     = "sleep 30 && ansible-playbook -i hosts main.yml"
  }
  depends_on = [ local_file.ansible_hosts ]
}
