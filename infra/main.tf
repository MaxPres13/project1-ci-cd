resource "azurerm_resource_group" "rg" {
  name     = "project1-rg"
  location = "westeurope"
}

resource "azurerm_service_plan" "plan" {
  name                = "project1-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Linux"
  sku_name = "S1"
}

resource "azurerm_container_registry" "acr" {
  name                = "project1registry"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_app_service" "app" {
  name                = "project1-frontend-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_service_plan.plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on        = true
    linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/project-1-frontend:latest"

    health_check_path                    = "/"
    acr_use_managed_identity_credentials = true
  }
}

resource "azurerm_app_service_slot" "staging" {
  name                = "staging"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_service_plan.plan.id
  app_service_name    = azurerm_app_service.app.name

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                            = true
    linux_fx_version                     = "DOCKER|${azurerm_container_registry.acr.login_server}/project-1-frontend:latest"
    health_check_path                    = "/"
    acr_use_managed_identity_credentials = true
  }
}




resource "azurerm_role_assignment" "acr_pull_app" {
  principal_id         = azurerm_app_service.app.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}


resource "azurerm_role_assignment" "acr_pull_staging" {
  principal_id         = azurerm_app_service_slot.staging.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "project1-autoscale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_service_plan.plan.id

  profile {
    name = "scale-based-on-memory"

    capacity {
      minimum = 1
      maximum = 3
      default = 1
    }

    rule {
      metric_trigger {
        metric_name        = "MemoryWorkingSet"
        metric_resource_id = azurerm_app_service.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 1024 # MB
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "MemoryWorkingSet"
        metric_resource_id = azurerm_app_service.app.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 300 # MB
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"
      }
    }
  }
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  name                = "project1-http-5xx"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_app_service.app.id]
  description         = "Too many server errors"
  severity            = 2
  enabled             = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.email_group.id
  }
}


resource "azurerm_monitor_action_group" "email_group" {
  name                = "project1-action-group"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "p1act"

  email_receiver {
    name                    = "default"
    email_address           = "maximilian-pres@web.de"
    use_common_alert_schema = true
  }
}
