data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_iam_instance_profile" "my_ssm_profile" {
  name = "AWS-SSM"
}

data "aws_eip" "web_server_eip" {
  id = "eipalloc-03b9886f81d2ce44f" // Reserved Elastic IP allocation ID for the web server
}

resource "aws_eip_association" "web_server_eip_assoc" {
  instance_id   = module.web_server.id
  allocation_id = data.aws_eip.web_server_eip.id
}
# data "aws_ssm_parameter" "token" {
#   name = "/devops-bootcamp-2026/tunnel-token"
# }

module "web_server" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 6.0"
  name                   = "web-server"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name // Attach the IAM instance profile for SSM access
  private_ip             = "10.0.0.5"                                        // Assign a specific private IP address to the web server
  subnet_id              = module.devops_vpc.public_subnets[0]               // Use the first public subnet
  create_security_group  = false
  vpc_security_group_ids = [module.devops_public_sg.id] // Use the security group created in the VPC module
  key_name               = "FedoraLab"
  tags                   = { Name = "web-server" }
  root_block_device      = { size = 16 } // Increase root volume size to 16GB
}

module "controller_node" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 6.0"
  name                   = "controller-node"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name // Attach the IAM instance profile for SSM access
  private_ip             = "10.0.0.135"                                      // Assign a specific private IP address to the controller node
  subnet_id              = module.devops_vpc.private_subnets[0]              // Use the first private subnet from the VPC module
  create_security_group  = false                                             // Disable security group creation since we are using an existing one
  vpc_security_group_ids = [module.devops_private_sg.id]
  key_name               = "FedoraLab"
  tags                   = { Name = "controller-node" }
  root_block_device      = { size = 16 } // Increase root volume size to 16GB
}

module "monitoring_node" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 6.0"
  name                   = "monitoring-node"
  ami                    = data.aws_ami.my_ami.id
  instance_type          = "t3.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.my_ssm_profile.name // Attach the IAM instance profile for SSM access
  private_ip             = "10.0.0.136"                                      // Assign a specific private IP address to the monitoring node
  subnet_id              = module.devops_vpc.private_subnets[0]              // Use the first private subnet from the VPC module
  create_security_group  = false                                             // Disable security group creation since we are using an existing one
  vpc_security_group_ids = [module.devops_private_sg.id]
  key_name               = "FedoraLab"
  tags                   = { Name = "monitoring-node" }
  root_block_device      = { size = 16 } // Increase root volume size to 16GB
}