terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  encryption {
    key_provider "external" "key_20250602" {
      command = ["sh", "-c",
        <<-EOT
          KEY="$(sops --extract '["tofu"]["key_20250602"]' -d $PRJ_ROOT/infra/secrets.yaml | base64 -w 0)"
          printf '{"magic": "OpenTofu-External-Key-Provider", "version": 1}\n'
          printf '{"keys": {"encryption_key": "%s", "decryption_key": "%s"}}\n' $KEY $KEY
        EOT
      ]
    }
    key_provider "pbkdf2" "key_20250602" {
      chain = key_provider.external.key_20250602
    }
    method "aes_gcm" "default" {
      keys = key_provider.pbkdf2.key_20250602
    }
    state {
      method   = method.aes_gcm.default
      enforced = true
    }
    plan {
      method   = method.aes_gcm.default
      enforced = true
    }
  }
}
