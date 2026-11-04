data "azurerm_subscription" "current" {}

resource "azurerm_policy_definition" "audit_open_ssh" {
  name         = "audit-nsg-open-ssh"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny NSG rules allowing unrestricted SSH access"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/networkSecurityGroups/securityRules"
        },
        {
          field  = "Microsoft.Network/networkSecurityGroups/securityRules/access"
          equals = "Allow"
        },
        {
          field  = "Microsoft.Network/networkSecurityGroups/securityRules/direction"
          equals = "Inbound"
        },
        {
          field  = "Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange"
          equals = "22"
        },
        {
          field  = "Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix"
          equals = "*"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "audit_open_ssh_assignment" {
  name                 = "audit-nsg-open-ssh-assignment"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.audit_open_ssh.id
  display_name         = "Assign Custom deny: NSG Open SSH"
}
