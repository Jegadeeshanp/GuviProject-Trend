module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = "trend-cluster-new"
  cluster_version = "1.29"

  vpc_id     = aws_vpc.main_vpc.id
  subnet_ids = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.small"]  
  }

  eks_managed_node_groups = {
    trend-ng = {
      min_size     = 1
      max_size     = 1
      desired_size = 1

      tags = {
        Name = "trend-ng-node"
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "trend"
  }
}

