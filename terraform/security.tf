module "devops_public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-public-sg"
  use_name_prefix = false
  vpc_id          = module.devops_vpc.vpc_id

  ingress_rules = {
    http = {
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "tcp"
      from_port   = 80
      to_port     = 80
    }
    node_exporter = {
      cidr_ipv4   = "10.0.0.136/32" // Allow access from the monitoring node's private IP address
      ip_protocol = "tcp"
      from_port   = 9100
      to_port     = 9100
    }
    ssh_controller = {
      cidr_ipv4   = "10.0.0.135/32" // Allow access from the controller node's private IP address
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  egress_rules = {
    all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
  }

  tags = { Name = "devops-project-public-sg-tf" }
}

module "devops_private_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  name            = "devops-private-sg"
  use_name_prefix = false
  vpc_id          = module.devops_vpc.vpc_id

  ingress_rules = {
    ssh_controller = {
      cidr_ipv4   = "10.0.0.135/32" // Allow access from the controller node's private IP address
      ip_protocol = "tcp"
      from_port   = 22
      to_port     = 22
    }
  }

  egress_rules = {
    all = { cidr_ipv4 = "0.0.0.0/0", ip_protocol = "-1" }
  }

  tags = { Name = "devops-project-private-sg-tf" }
}
