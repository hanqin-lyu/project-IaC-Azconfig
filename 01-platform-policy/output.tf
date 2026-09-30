output "policy_definition_id" {
  value = azurerm_policy_definition.audit_open_ssh.id
}

output "policy_assignment_id" {
  value = azurerm_resource_group_policy_assignment.audit_open_ssh_assignment.id
}