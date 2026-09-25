output "key_vault_uri" {
  value = module.avm-res-keyvault-vault.uri
}

output "vnet_id" {
  value = module.avm-res-network-virtualnetwork.resource_id
}

output "sql_server_fqdn" {
  value = module.avm-res-sql-server.resource.fully_qualified_domain_name
}