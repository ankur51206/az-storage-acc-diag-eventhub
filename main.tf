# My Providers start 
provider "azurerm" {
  features {}
}

data "azurerm_management_group" "baringsroot" {
  display_name = "ankur management group"
}

# My Provider finish

data "azurerm_user_assigned_identity" "myazpolicy" {
  name                = "MyIdentity"
  resource_group_name = "sample-1"
}

resource "azurerm_policy_definition" "storage_diaglogs" {
  name         = "diag-logs-storage-eventhub"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "enable diagnostic setting for storage account"

  metadata = <<METADATA
    {
    "category": "General"
    }
METADATA

  parameters = <<PARAMETERS

	{
		"eventHubAuthorizationRuleId": {
			"type": "String",
			"metadata": {
				"displayName": "Event Hub Shared Access Policy Authorization Rule Id",
				"description": "Specify Event Hub Shared Access Policy Authorization Rule Id"
			}
		},
		"Location": {
			"type": "String",
			"metadata": {
				"displayName": "Resource Location",
				"description": "Resource Location must be the same as the Event Hub Location",
				"strongType": "location"
			}
		},
		"servicesToDeploy": {
			"type": "Array",
			"metadata": {
				"displayName": "Storage services to deploy",
				"description": "List of Storage services to deploy"
			},
			"allowedValues": [
				"storageAccounts",
				"blobServices",
				"fileServices",
				"tableServices",
				"queueServices"
			],
			"defaultValue": [
				"storageAccounts",
				"blobServices",
				"fileServices",
				"tableServices",
				"queueServices"
			]
		},
		"diagnosticsSettingNameToUse": {
			"type": "String",
			"metadata": {
				"displayName": "Setting name",
				"description": "Name of the diagnostic settings."
			},
			"defaultValue": "diagSetByAzPolicyEventHub"
		},
		"effect": {
			"type": "String",
			"metadata": {
				"displayName": "Effect",
				"description": "Enable or disable the execution of the policy"
			},
			"allowedValues": [
				"DeployIfNotExists",
				"Disabled"
			],
			"defaultValue": "DeployIfNotExists"
		},
		"StorageDelete": {
			"type": "String",
			"metadata": {
				"displayName": "StorageDelete - Enabled",
				"description": "Whether to stream StorageDelete logs to the Log Analytics workspace - True or False"
			},
			"allowedValues": [
				"True",
				"False"
			],
			"defaultValue": "True"
		},
		"StorageWrite": {
			"type": "String",
			"metadata": {
				"displayName": "StorageWrite - Enabled",
				"description": "Whether to stream StorageWrite logs to the Log Analytics workspace - True or False"
			},
			"allowedValues": [
				"True",
				"False"
			],
			"defaultValue": "True"
		},
		"StorageRead": {
			"type": "String",
			"metadata": {
				"displayName": "StorageRead - Enabled",
				"description": "Whether to stream StorageRead logs to the Log Analytics workspace - True or False"
			},
			"allowedValues": [
				"True",
				"False"
			],
			"defaultValue": "True"
		},
		"Transaction": {
			"type": "String",
			"metadata": {
				"displayName": "Transaction - Enabled",
				"description": "Whether to stream Transaction logs to the Log Analytics workspace - True or False"
			},
			"allowedValues": [
				"True",
				"False"
			],
			"defaultValue": "True"
		}
	}

PARAMETERS


  policy_rule = <<POLICY_RULE

{
	"if": {
		"allOf": [{
				"field": "type",
				"equals": "Microsoft.Storage/storageAccounts"
			},
			{
				"field": "location",
				"equals": "[parameters('Location')]"
			}
		]
	},
	"then": {
		"effect": "[parameters('effect')]",
		"details": {
			"type": "Microsoft.Insights/diagnosticSettings",
			"roleDefinitionIds": [
				"/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
			],
			"existenceCondition": {
				"allOf": [{
						"field": "Microsoft.Insights/diagnosticSettings/metrics.enabled",
						"equals": "True"
					},
					{
						"field": "Microsoft.Insights/diagnosticSettings/logs.enabled",
						"equals": "True"
					},
					{
						"field": "Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId",
						"matchInsensitively": "[parameters('eventHubAuthorizationRuleId')]"
					}
				]
			},
			"deployment": {
				"properties": {
					"mode": "incremental",
					"template": {
						"$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
						"contentVersion": "1.0.0.0",
						"parameters": {
							"servicesToDeploy": {
								"type": "array"
							},
							"diagnosticsSettingNameToUse": {
								"type": "string"
							},
							"resourceName": {
								"type": "string"
							},
							"eventHubAuthorizationRuleId": {
								"type": "string"
							},
							"location": {
								"type": "string"
							},
							"Transaction": {
								"type": "string"
							},
							"StorageRead": {
								"type": "string"
							},
							"StorageWrite": {
								"type": "string"
							},
							"StorageDelete": {
								"type": "string"
							}
						},
						"variables": {},
						"resources": [{
								"condition": "[contains(parameters('servicesToDeploy'), 'blobServices')]",
								"type": "Microsoft.Storage/storageAccounts/blobServices/providers/diagnosticSettings",
								"apiVersion": "2017-05-01-preview",
								"name": "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]",
								"location": "[parameters('location')]",
								"dependsOn": [],
								"properties": {
									"eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
									"metrics": [{
										"category": "Transaction",
										"enabled": "[parameters('Transaction')]"
									}],
									"logs": [{
											"category": "StorageRead",
											"enabled": "[parameters('StorageRead')]"
										},
										{
											"category": "StorageWrite",
											"enabled": "[parameters('StorageWrite')]"
										},
										{
											"category": "StorageDelete",
											"enabled": "[parameters('StorageDelete')]"
										}
									]
								}
							},
							{
								"condition": "[contains(parameters('servicesToDeploy'), 'fileServices')]",
								"type": "Microsoft.Storage/storageAccounts/fileServices/providers/diagnosticSettings",
								"apiVersion": "2017-05-01-preview",
								"name": "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]",
								"location": "[parameters('location')]",
								"dependsOn": [],
								"properties": {
									"eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
									"metrics": [{
										"category": "Transaction",
										"enabled": "[parameters('Transaction')]"
									}],
									"logs": [{
											"category": "StorageRead",
											"enabled": "[parameters('StorageRead')]"
										},
										{
											"category": "StorageWrite",
											"enabled": "[parameters('StorageWrite')]"
										},
										{
											"category": "StorageDelete",
											"enabled": "[parameters('StorageDelete')]"
										}
									]
								}
							},
							{
								"condition": "[contains(parameters('servicesToDeploy'), 'tableServices')]",
								"type": "Microsoft.Storage/storageAccounts/tableServices/providers/diagnosticSettings",
								"apiVersion": "2017-05-01-preview",
								"name": "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]",
								"location": "[parameters('location')]",
								"dependsOn": [],
								"properties": {
									"eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
									"metrics": [{
										"category": "Transaction",
										"enabled": "[parameters('Transaction')]"
									}],
									"logs": [{
											"category": "StorageRead",
											"enabled": "[parameters('StorageRead')]"
										},
										{
											"category": "StorageWrite",
											"enabled": "[parameters('StorageWrite')]"
										},
										{
											"category": "StorageDelete",
											"enabled": "[parameters('StorageDelete')]"
										}
									]
								}
							},
							{
								"condition": "[contains(parameters('servicesToDeploy'), 'queueServices')]",
								"type": "Microsoft.Storage/storageAccounts/queueServices/providers/diagnosticSettings",
								"apiVersion": "2017-05-01-preview",
								"name": "[concat(parameters('resourceName'), '/default/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]",
								"location": "[parameters('location')]",
								"dependsOn": [],
								"properties": {
									"eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
									"metrics": [{
										"category": "Transaction",
										"enabled": "[parameters('Transaction')]"
									}],
									"logs": [{
											"category": "StorageRead",
											"enabled": "[parameters('StorageRead')]"
										},
										{
											"category": "StorageWrite",
											"enabled": "[parameters('StorageWrite')]"
										},
										{
											"category": "StorageDelete",
											"enabled": "[parameters('StorageDelete')]"
										}
									]
								}
							},
							{
								"condition": "[contains(parameters('servicesToDeploy'), 'storageAccounts')]",
								"type": "Microsoft.Storage/storageAccounts/providers/diagnosticSettings",
								"apiVersion": "2017-05-01-preview",
								"name": "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('diagnosticsSettingNameToUse'))]",
								"location": "[parameters('location')]",
								"dependsOn": [],
								"properties": {
									"eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
									"metrics": [{
										"category": "Transaction",
										"enabled": "[parameters('Transaction')]"
									}]
								}
							}
						],
						"outputs": {}
					},
					"parameters": {
						"diagnosticsSettingNameToUse": {
							"value": "[parameters('diagnosticsSettingNameToUse')]"
						},
						"eventHubAuthorizationRuleId": {
							"value": "[parameters('eventHubAuthorizationRuleId')]"
						},
						"Location": {
							"value": "[field('location')]"
						},
						"resourceName": {
							"value": "[field('name')]"
						},
						"Transaction": {
							"value": "[parameters('Transaction')]"
						},
						"StorageDelete": {
							"value": "[parameters('StorageDelete')]"
						},
						"StorageWrite": {
							"value": "[parameters('StorageWrite')]"
						},
						"StorageRead": {
							"value": "[parameters('StorageRead')]"
						},
						"servicesToDeploy": {
							"value": "[parameters('servicesToDeploy')]"
						}
					}
				}
			}
		}
	}
}

POLICY_RULE
}

data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "assign_policy" {
  name                 = "policy-assignment-storage-eventhub"
  policy_definition_id = azurerm_policy_definition.storage_diaglogs.id
  subscription_id      = data.azurerm_subscription.current.id
  location             = "eastus"
  parameters           = <<PARAMETERS
    {
      "eventHubAuthorizationRuleId": {
        "value": "/subscriptions/f3d20c9f-3cb5-45df-b6a8-32f7f4e3d1b6/resourcegroups/sample-1/providers/Microsoft.EventHub/namespaces/myeventhubsank/authorizationrules/RootManageSharedAccessKey"
      },
	     "Location": {
        "value": "eastus"
      }
    }
  PARAMETERS

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.myazpolicy.id]

  }

}
