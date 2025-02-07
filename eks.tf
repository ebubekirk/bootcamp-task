module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    main = {
      name            = "main-node-group"
      use_name_prefix = true

      subnet_ids = module.vpc.public_subnets

      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.micro"]

      # Proper bootstrap configuration
      bootstrap_extra_args = <<-EOT
        --kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'
      EOT

      # Use the default EKS-optimized AMI
      ami_type = "AL2_x86_64"

      # Enable public IP
      network_interfaces = [{
        associate_public_ip_address = true
        delete_on_termination       = true
      }]
    }
  }

  # Additional security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
