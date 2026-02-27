output "instance_ids" { value = aws_instance.app[*].id }
output "volume_ids" { value = aws_ebs_volume.data[*].id }
