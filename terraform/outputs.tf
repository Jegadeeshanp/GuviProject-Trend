output "jenkins_public_ip" {
  description = "Public IP of Jenkins EC2 instance"
  value       = aws_instance.jenkins_ec2.public_ip
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnets" {
  value = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

