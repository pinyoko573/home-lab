# ---------- Create log analytics workspace ----------
resource "azurerm_log_analytics_workspace" "log-homelab" {
  name                = "log-homelab"
  resource_group_name = var.rg.name
  location            = var.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ---------- Create data collection rules ----------
# Linux
resource "azurerm_monitor_data_collection_rule" "dcr-homelab-001" {
  name                = "dcr-homelab-001"
  resource_group_name = var.rg.name
  location            = var.rg.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log-homelab.id
      name                  = "linux-destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["linux-destination-log"]
  }

  data_sources {
    syslog {
      facility_names = ["auth"]
      log_levels     = ["Info"]
      name           = "linux-datasource-syslog"
      streams        = ["Microsoft-Syslog"]
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.log-homelab
  ]
}

# Onboarding Linux Azure Arc
data "azurerm_arc_machine" "ubuntu-svr01" {
  name                = "ubuntu-svr01"
  resource_group_name = var.rg.name
}

resource "azurerm_arc_machine_extension" "ubuntu-svr01-ext" {
  name           = "ubuntu-svr01-ext"
  location       = var.rg.location
  arc_machine_id = data.azurerm_arc_machine.ubuntu-svr01.id
  publisher      = "Microsoft.Azure.Monitor"
  type           = "AzureMonitorLinuxAgent"
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-homelab-001" {
  name                    = "dcra-homelab-001"
  target_resource_id      = data.azurerm_arc_machine.ubuntu-svr01.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr-homelab-001.id
}

# Windows
resource "azurerm_monitor_data_collection_rule" "dcr-homelab-002" {
  name                = "dcr-homelab-002"
  resource_group_name = var.rg.name
  location            = var.rg.location
  kind                = "Windows"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log-homelab.id
      name                  = "windows-destination-log"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["windows-destination-log"]
  }

  data_sources {
    windows_event_log {
      streams        = ["Microsoft-Event"]
      x_path_queries = ["ForwardedEvents!*[System[(EventID=4768 or EventID=4769)]]"]
      name           = "windows-datasource-wineventlog"
    }
  }

  depends_on = [
    azurerm_log_analytics_workspace.log-homelab
  ]
}

# Onboarding Windows Azure Arc
data "azurerm_arc_machine" "WIN-SVR02" {
  name                = "WIN-SVR02"
  resource_group_name = var.rg.name
}

resource "azurerm_arc_machine_extension" "WIN-SVR02-ext" {
  name           = "WIN-SVR02-ext"
  location       = var.rg.location
  arc_machine_id = data.azurerm_arc_machine.WIN-SVR02.id
  publisher      = "Microsoft.Azure.Monitor"
  type           = "AzureMonitorWindowsAgent"
}

resource "azurerm_monitor_data_collection_rule_association" "dcra-homelab-002" {
  name                    = "dcra-homelab-002"
  target_resource_id      = data.azurerm_arc_machine.WIN-SVR02.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr-homelab-002.id
}

# ---------- Onboard to Sentinel ----------
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "log_onboarding-homelab" {
  workspace_id                 = azurerm_log_analytics_workspace.log-homelab.id
  customer_managed_key_enabled = false

  depends_on = [
    azurerm_log_analytics_workspace.log-homelab
  ]
}