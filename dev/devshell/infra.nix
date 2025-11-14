# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/7b5cb693088c2996418d44a3f1203680762ed97d/devshell/terraform.nix (MIT License)
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        commands = map (cmd: cmd // { category = "infra"; }) [
          {
            package = pkgs.opentofu.withPlugins (
              ps: with ps; [
                # keep-sorted start
                carlpett_sops
                hashicorp_random
                hashicorp_tls
                pkgs.terraform-providers-bin.providers.Backblaze.b2
                vultr_vultr
                # keep-sorted end
              ]
            );
            help = "Tool for building, changing, and versioning infrastructure";
          }
          {
            package = pkgs.writeShellApplication {
              name = "tofu-outputs-update";
              text = ''
                # shellcheck disable=SC2094
                tofu -chdir="$PRJ_ROOT/infra" output --json |
                  sops --input-type json --output-type yaml \
                    --filename-override "$PRJ_ROOT/infra/outputs.yaml" \
                    --encrypt /dev/stdin \
                    >"$PRJ_ROOT/infra/outputs.yaml"
              '';
            };
            help = "Export and encrypt OpenTofu outputs to infra/outputs.yaml";
          }
          {
            package = pkgs.writeShellApplication {
              name = "tofu-outputs-extract-data";
              runtimeInputs = with pkgs; [ jq ];
              text = ''
                sops exec-file "$PRJ_ROOT/infra/outputs.yaml" --output-type json \
                  "jq --from-file $PRJ_ROOT/infra/data.jq {}" \
                  >"$PRJ_ROOT/infra/data.json"
              '';
            };
            help = "Extract non-sensitive data from infra/outputs.yaml";
          }
          {
            package = pkgs.writeShellApplication {
              name = "tofu-outputs-extract-secrets";
              runtimeInputs = with pkgs; [ jq ];
              text = ''
                tmp_dir=$(mktemp -t --directory tofu-outputs-extract-secrets.XXXXXXXXXX)
                function cleanup {
                  rm -r "$tmp_dir"
                }
                trap cleanup EXIT

                mapfile -t hosts < <(nix eval "$PRJ_ROOT"#nixosConfigurations --apply 'c: (builtins.concatStringsSep "\n" (builtins.attrNames c))' --raw)

                for name in "''${hosts[@]}"; do
                  echo "> start extracting secrets for $name..."

                  template_file="$tmp_dir/$name.jq"
                  nix eval "$PRJ_ROOT"#nixosConfigurations."$name".config.sops.opentofuTemplate --json |
                    jq -n --raw-output --slurpfile data /dev/stdin '
                      def unwrap(obj):
                        if obj | type == "object" then
                          "{"+(obj | to_entries | map("\""+.key+"\": "+unwrap(.value)) | join(", "))+"}"
                        elif obj | type == "array" then
                          "["+(obj | map(unwrap(.)) | join(", "))+"]"
                        else
                          obj
                        end;
                      unwrap($data[0])
                    ' >"$template_file"

                  target_file="$PRJ_ROOT/secrets/hosts/opentofu/$name.yaml"
                  mkdir -p "$(dirname "$target_file")"
                  # shellcheck disable=SC2094
                  sops exec-file "$PRJ_ROOT/infra/outputs.yaml" --output-type json \
                    "jq --from-file '$template_file' {}" |
                    sops --input-type json --output-type yaml \
                      --filename-override "$target_file" \
                      --encrypt /dev/stdin \
                      >"$target_file"
                done
              '';
            };
            help = "Extract secrets from infra/outputs.yaml";
          }
          {
            package = pkgs.writeShellApplication {
              name = "tofu-sync";
              text = ''
                tofu-outputs-update
                tofu-outputs-extract-data
                tofu-outputs-extract-secrets
                nix fmt
              '';
            };
            help = "Sync OpenTofu state with repository data and secrets";
          }
        ];
      };
    };
}
