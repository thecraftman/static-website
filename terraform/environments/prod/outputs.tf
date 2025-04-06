output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}

output "website_url" {
  description = "URL of the production website"
  value       = "https://${var.domain_name}"
}

output "load_balancer_hostname" {
  description = "Hostname of the load balancer for DNS configuration"
  value       = "After deployment, get the ALB hostname with: kubectl get ingress -n xayn-prod -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'"
}