module "devops_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "devops_vpc"
  cidr = "10.0.0.0/24"
  azs  = ["ap-southeast-1a"]

  public_subnets  = ["10.0.0.0/25"]
  private_subnets = ["10.0.0.128/25"]

  manage_default_security_group = false // Disable management of the default security group to avoid conflicts with custom security groups
  enable_nat_gateway            = true  // Enable NAT gateway for private subnet access to the internet

  nat_gateway_tags         = { Name = "devops-NGW" }
  igw_tags                 = { Name = "devops-IGW" }
  public_route_table_tags  = { Name = "devops-public-RT" }
  private_route_table_tags = { Name = "devops-private-RT" }
}