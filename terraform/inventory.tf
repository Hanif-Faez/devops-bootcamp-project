resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/../ansible/inventory.ini.tftpl", {
    web_server      = { private_ip = module.web_server.private_ip }
    monitoring_node = { private_ip = module.monitoring_node.private_ip }
  })
}