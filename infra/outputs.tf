output "production_url" {
  value = azurerm_app_service.app.default_site_hostname
}

output "staging_url" {
  value = azurerm_app_service_slot.staging.default_site_hostname
}
