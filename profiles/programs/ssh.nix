# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/b618b0fd16fb9c79ab7199ed51c4c0f98a392cea/nixos/profiles/services/openssh/default.nix (MIT License)
{ lib, meta, ... }:
let
  inherit (lib.attrsets) mapAttrs' nameValuePair attrNames;
  inherit (lib.strings) concatMapStringsSep;
in
{
  flake.unify.modules."programs/ssh" = {
    nixos = {
      module =
        { ... }:
        let
          aliveInterval = "15";
          aliveCountMax = "4";

          knownHosts = mapAttrs' (
            host: hostData:
            nameValuePair "${host}-ed25519" {
              hostNames = [
                "${host}.rebmit.link"
                "${host}.enta.rebmit.link"
              ];
              publicKey = hostData.ssh_host_ed25519_key_pub;
            }
          ) meta.data.hosts;
        in
        {
          programs.ssh = {
            inherit knownHosts;
            extraConfig = ''
              ServerAliveInterval ${aliveInterval}
              ServerAliveCountMax ${aliveCountMax}
            ''
            + concatMapStringsSep "\n" (h: ''
              Host ${h}
                Hostname ${h}.rebmit.link
                Port ${toString meta.ports.ssh}
              Host ${h}.enta
                Hostname ${h}.enta.rebmit.link
                Port ${toString meta.ports.ssh}
            '') (attrNames meta.data.hosts);
          };
        };
    };

    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          preservation.preserveAt.state.directories = [ ".ssh" ];
        };
    };
  };
}
