locals {
  hosts = {
    "marisa-7d76" = {
      endpoints_v4               = []
      endpoints_v6               = []
      enthalpy_node_id           = parseint("d79", 16)
      enthalpy_node_organization = "enta0004"
    }
    "marisa-j715" = {
      endpoints_v4               = []
      endpoints_v6               = []
      enthalpy_node_id           = parseint("572", 16)
      enthalpy_node_organization = "enta0004"
    }
    "flandre-m5p" = {
      endpoints_v4               = []
      endpoints_v6               = []
      enthalpy_node_id           = parseint("a23", 16)
      enthalpy_node_organization = "enta0003"
    }
    "flandre-t1" = {
      endpoints_v4               = []
      endpoints_v6               = []
      enthalpy_node_id           = parseint("397", 16)
      enthalpy_node_organization = "enta0003"
    }
    "kogasa-iad0" = {
      endpoints_v4               = ["152.53.167.21"]
      endpoints_v6               = ["2a0a:4cc0:2000:9bab::1"]
      enthalpy_node_id           = parseint("3f9", 16)
      enthalpy_node_organization = "enta0002"
    }
    "kogasa-iad1" = {
      endpoints_v4               = ["152.53.52.89"]
      endpoints_v6               = ["2a0a:4cc0:2000:2cf6:18a1:5eff:fe4b:7cec"]
      enthalpy_node_id           = parseint("910", 16)
      enthalpy_node_organization = "enta0002"
    }
    "kogasa-nue0" = {
      endpoints_v4               = ["152.53.188.16"]
      endpoints_v6               = ["2a00:11c0:5f:2a13:28d1:f7ff:fe54:a589"]
      enthalpy_node_id           = parseint("bf7", 16)
      enthalpy_node_organization = "enta0002"
    }
    "kanako-ham0" = {
      endpoints_v4               = ["91.108.80.168"]
      endpoints_v6               = ["2a05:901:6:1015::1"]
      enthalpy_node_id           = parseint("2d8", 16)
      enthalpy_node_organization = "enta0002"
    }
    "reisen-fra0" = {
      endpoints_v4               = [module.vultr_instances["reisen-fra0"].ipv4]
      endpoints_v6               = [module.vultr_instances["reisen-fra0"].ipv6]
      enthalpy_node_id           = parseint("38c", 16)
      enthalpy_node_organization = "enta0001"
    }
    "reisen-nrt0" = {
      endpoints_v4               = [module.vultr_instances["reisen-nrt0"].ipv4]
      endpoints_v6               = [module.vultr_instances["reisen-nrt0"].ipv6]
      enthalpy_node_id           = parseint("586", 16)
      enthalpy_node_organization = "enta0001"
    }
    "reisen-sea0" = {
      endpoints_v4               = [module.vultr_instances["reisen-sea0"].ipv4]
      endpoints_v6               = [module.vultr_instances["reisen-sea0"].ipv6]
      enthalpy_node_id           = parseint("6b8", 16)
      enthalpy_node_organization = "enta0001"
    }
  }
}

module "hosts" {
  source                     = "./modules/host"
  for_each                   = local.hosts
  name                       = each.key
  endpoints_v4               = each.value.endpoints_v4
  endpoints_v6               = each.value.endpoints_v6
  enthalpy_organizations     = local.enthalpy_organizations
  enthalpy_private_key       = tls_private_key.enthalpy
  enthalpy_node_id           = each.value.enthalpy_node_id
  enthalpy_node_organization = each.value.enthalpy_node_organization
}

output "hosts" {
  value     = module.hosts
  sensitive = true
}

output "hosts_non_sensitive" {
  value = {
    for host, outputs in module.hosts :
    host => {
      for name, output in outputs :
      name => output if !issensitive(output)
    }
  }
  sensitive = false
}
