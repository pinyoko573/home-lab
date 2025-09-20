# ---------- Sentinel schedule rules: Potential Kerberoasting ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-potential_kerberoasting-homelab" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_onboarding-homelab.workspace_id
  name = "potential_kerberoasting"
  display_name = "Potential Kerberoasting"
  description = "A Kerberos ticket-granting service (TGS) for a Service Principal Name (SPN) was requested from the domain controller. The password hash in the requested ticket may be obtained to get the plaintext password of the service account through brute force techniques. Attackers usually request for TGS tickets with RC4 encryption standard due to weak cryptography algorithm."
  severity = "Low"
  enabled = true
  query = <<EOF
  Event
  | where EventID == 4769
  | extend CleanXml = replace(@'\s+xmlns="[^"]*"', "", EventData)
  | extend Parsed = parse_xml(CleanXml)
  | mv-expand DataNode = Parsed.DataItem.EventData.Data
  | extend Field = tostring(DataNode['@Name']),
            Value = tostring(DataNode['#text'])
  | summarize Bag = make_bag(pack(Field, Value)) by TimeGenerated, EventID
  | evaluate bag_unpack(Bag)
  | extend TicketEncryptionType = column_ifexists("TicketEncryptionType", '')
  | where TicketEncryptionType == "0x17"
  | extend TargetUserName = column_ifexists("TargetUserName", '')
  | extend TargetDomainName = column_ifexists("TargetDomainName", '')
  | extend IpAddress = column_ifexists("IpAddress", '')
  | extend ServiceName = column_ifexists("ServiceName", '')
  | extend userName = split(TargetUserName, '@')[0]
  | extend IpAddress_V4 = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, IpAddress)
  EOF
  query_frequency = "PT10M"
  query_period = "PT1H"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["CredentialAccess"]
  techniques = ["T1558"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "TargetDomainName"
      identifier = "NTDomain"
    }
    field_mapping {
      column_name = "userName"
      identifier = "Name"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      column_name = "IpAddress_V4"
      identifier = "Address"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}

# ---------- Sentinel schedule rules: Potential AS-REP Roasting ----------
resource "azurerm_sentinel_alert_rule_scheduled" "log_rule-potential_asreproasting-homelab" {
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.log_onboarding-homelab.workspace_id
  name = "potential_asreproasting"
  display_name = "Potential AS-REP Roasting"
  description = "When an account has enabled 'Do not require Kerberos preauthentication', an attacker can request for a Kerberos ticket-granting ticket (TGT) for that account without pre-authentication. The password hash in the requested ticket may be obtained to get the plaintext password of the account through brute force techniques. Attackers usually request for TGT tickets with RC4 encryption standard due to weak cryptography algorithm."
  severity = "Low"
  enabled = true
  query = <<EOF
  Event
  | where EventID == 4768
  | extend CleanXml = replace(@'\s+xmlns="[^"]*"', "", EventData)
  | extend Parsed = parse_xml(CleanXml)
  | mv-expand DataNode = Parsed.DataItem.EventData.Data
  | extend
      Field = tostring(DataNode['@Name']),
      Value = tostring(DataNode['#text'])
  | summarize Bag = make_bag(pack(Field, Value)) by TimeGenerated, EventID
  | evaluate bag_unpack(Bag)
  | extend PreAuthType = column_ifexists("PreAuthType", '')
  | where PreAuthType == "0"
  | extend SessionKeyEncryptionType = column_ifexists("SessionKeyEncryptionType", '')
  | where SessionKeyEncryptionType == "0x17"
  | extend ServiceName = column_ifexists("ServiceName", '')
  | where ServiceName == "krbtgt"
  | extend TargetUserName = column_ifexists("TargetUserName", '')
  | extend TargetDomainName = column_ifexists("TargetDomainName", '')
  | extend IpAddress = column_ifexists("IpAddress", '')
  | extend userName = split(TargetUserName, '@')[0]
  | extend IpAddress_V4 = extract(@"(\d+\.\d+\.\d+\.\d+)", 1, IpAddress)
  EOF
  query_frequency = "PT10M"
  query_period = "PT1H"
  suppression_duration = "PT5H"
  suppression_enabled = false
  tactics = ["CredentialAccess"]
  techniques = ["T1558"]
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      column_name = "TargetDomainName"
      identifier = "NTDomain"
    }
    field_mapping {
      column_name = "userName"
      identifier = "Name"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      column_name = "IpAddress_V4"
      identifier = "Address"
    }
  }
  event_grouping {
    aggregation_method = "SingleAlert"
  }
  incident {
    create_incident_enabled = true
    grouping {
      by_alert_details = []
      by_custom_details = []
      by_entities = []
      enabled = false
      entity_matching_method = "AllEntities"
      lookback_duration = "PT5H"
      reopen_closed_incidents = false
    }
  }
}