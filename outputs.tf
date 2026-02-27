# Outputs: module refs, resource refs, for expression

output "vpc_id" {
  value = local.vpc_id
}

output "app_instance_ids" {
  value = try(module.app_web[0].instance_ids, [])
}

output "all_worker_instances" {
  value = try(aws_instance.workers[*].id, [])
}

output "module_outputs" {
  value = {
    for k, v in module.app_env : k => v.instance_ids
  }
}

output "base_vpc_id" {
  value = module.base_vpc.vpc_id
}

output "stack_vpc_id" {
  value = module.stack_vpc.vpc_id
}
