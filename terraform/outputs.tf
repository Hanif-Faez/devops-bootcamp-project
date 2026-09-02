output "web_server" {
  value = {
    public_ip  = data.aws_eip.web_server_eip.public_ip
    private_ip = module.web_server.private_ip
    ssm        = "aws ssm start-session --target ${module.web_server.id}"
  }
}

output "controller_node" {
  value = {
    private_ip = module.controller_node.private_ip
    ssm        = "aws ssm start-session --target ${module.controller_node.id}"
  }
}

output "monitoring_node" {
  value = {
    private_ip = module.monitoring_node.private_ip
    ssm        = "aws ssm start-session --target ${module.monitoring_node.id}"
  }
}