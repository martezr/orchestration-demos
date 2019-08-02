output "kubemaster_ip_address" {
  description = "Private IP of instance"
  value       = "${join(",", vsphere_virtual_machine.kubernetes-master.*.default_ip_address)}"
}

output "kubeworker_ip_address" {
  description = "Private IP of instance"
  value       = "${join(",", vsphere_virtual_machine.kubernetes-worker.*.default_ip_address)}"
}
