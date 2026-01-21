ephemeral "sops_file" "secrets" {
  source_file = "secrets.yaml"
}

locals {
  secrets = yamldecode(ephemeral.sops_file.secrets.raw)
}
