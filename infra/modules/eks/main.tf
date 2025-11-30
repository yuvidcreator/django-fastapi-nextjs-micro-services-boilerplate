module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "18.0.0" # pin a stable version

    cluster_name    = "${var.app_name}-${terraform.workspace}-eks"
    cluster_version = var.k8s_version
    subnets         = module.network.private_subnets
    vpc_id          = module.network.vpc_id

    node_groups = {
        ng_default = {
        desired_capacity = 2
        max_capacity     = 4
        min_capacity     = 2
        instance_types   = ["t3.medium"]
        tags = { "k8s.io/cluster-autoscaler/enabled" = "true" }
        }
    }

    map_roles = var.map_roles # optional map of role ARNs to map to cluster admin
    tags = local.common_tags
}

output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "cluster_oidc_issuer" { value = module.eks.cluster_oidc_issuer }
