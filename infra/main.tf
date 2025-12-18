resource "azurerm_resource_group" "rg" {
    name = "project1-rg"
    location = "westeurope"
}

resource "azurerm_service_plan" "plan" {
    name = "project1-plan"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    os_type = "Linux"
    sku_name = "S1"
}

resource "azurerm_container_registry" "acr" {
    name = "project1registry"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku = "Basic"
    admin_enabled = false
}

resource "azurerm_linux_web_app" "app" {
    name = "project1-frontend-app"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.plan.id

    identity {
        type = "SystemAssigned"
    }

    site_config {
        linux_fx_version =  "DOCKER|${azurerm_container_registry.acr.login_server}/project-1-frontend:latest"
    }
}

resource "azurerm_linux_web_app_slot" "staging" {
    name = "staging"
    app_service_id = azurerm_linux_web_app.app.id

    identity {
        type = "SystemAssigned"
    }

       site_config {
        linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/project-1-frontend:latest"
    }
}

resource "azurerm_role_assignment" "acr_pull_app" {
    principal_id = azurerm_linux_web_app.app.identity[0].principal_id
    role_definition_name = "AcrPull"
    scope = azurerm_container_registry.acr.id
}

resource "azurerm_role_assignment" "acr_pull_staging" {
    principal_id = azurerm_linux_web_app_slot.staging.identity[0].principal_id
    role_definition_name = "AcrPull"
    scope = azurerm_container_registry.acr.id
}