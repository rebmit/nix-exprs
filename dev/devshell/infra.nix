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
              text = ''
                sops exec-file "$PRJ_ROOT/infra/outputs.yaml" --output-type json \
                  "jq --from-file $PRJ_ROOT/infra/data.jq {}" \
                  >"$PRJ_ROOT/infra/data.json"
              '';
            };
            help = "Extract non-sensitive data from infra/outputs.yaml";
          }
        ];
      };
    };
}
