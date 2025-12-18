output "production_url" {
value = azurerm_linux_web_app.app.default_hostname
}

output "staging_url" {
    value = azurerm_linux_web_app_slot.staging.default_hostname
}