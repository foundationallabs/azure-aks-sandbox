output "vnet" {
  value = {
    id         = data.azurerm_virtual_network.existing.id
    name       = data.azurerm_virtual_network.existing.name
    subnet_ids = [data.azurerm_subnet.existing.id]
  }
  description = "A map of vnet attributes: name, subnet_ids."
}


output "public_domain" {
  value = {
    nameservers = []
    name        = ""
    id          = ""
  }
  description = "A map of public domain attributes: nameservers, name, id."
}

output "internal_domain" {
  value = {
    nameservers = []
    name        = ""
    id          = ""
  }
  description = "A map of internal domain attributes: nameservers, name, id."
}

# The Pace connector is outbound-only (no ingress), so it never needs a Nuon
# DNS zone. ctl-api's ProvisionDNS workflow still reads this output, so it is
# kept and hardcoded to the disabled shape (enabled = false, empty zones).
output "nuon_dns" {
  value = {
    enabled = false
    public_domain = {
      zone_id     = ""
      name        = ""
      nameservers = tolist([])
    }
    internal_domain = {
      zone_id     = ""
      name        = ""
      nameservers = tolist([])
    }
    alb_ingress_controller = {
      enabled  = false
      id       = ""
      chart    = ""
      revision = ""
    }
    external_dns = {
      enabled  = false
      id       = ""
      chart    = ""
      revision = ""
    }
    cert_manager = {
      enabled  = false
      id       = ""
      chart    = ""
      revision = ""
    }
    ingress_nginx = {
      enabled  = false
      id       = ""
      chart    = ""
      revision = ""
    }
  }
  description = "A map of Nuon DNS attributes matching the structure expected by ctl-api ProvisionDNS workflow for Route53 NS delegation."
}

output "account" {
  value = {
    "location"            = var.location
    "subscription_id"     = data.azurerm_client_config.current.subscription_id
    "client_id"           = data.azurerm_client_config.current.client_id
    "resource_group_name" = data.azurerm_resource_group.rg.name
  }
  description = "A map of Azure account attributes: location, subscription_id, client_id, resource_group_name."
}

output "cluster" {
  value = {
    "id"                     = module.aks.aks_id
    "name"                   = module.aks.aks_name
    "client_certificate"     = nonsensitive(module.aks.client_certificate)
    "client_key"             = nonsensitive(module.aks.client_key)
    "cluster_ca_certificate" = nonsensitive(module.aks.cluster_ca_certificate)
    "cluster_fqdn"           = module.aks.cluster_fqdn
    "oidc_issuer_url"        = module.aks.oidc_issuer_url
    "location"               = module.aks.location
    "kube_config_raw"        = nonsensitive(module.aks.kube_config_raw)
    "kube_admin_config_raw"  = nonsensitive(module.aks.kube_admin_config_raw)
    host                     = nonsensitive(module.aks.host)
  }
  description = "A map of AKS cluster attributes: id, name, client_certificate, client_key, cluster_ca_certificate, cluster_fqdn, oidc_issuer_url, location, kube_config_raw, kube_admin_config_raw."
}
