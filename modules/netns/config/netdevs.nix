# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/e9b255a8c4b9df882fdbcddb45ec59866a4a8e7c/nixos/modules/tasks/network-interfaces-scripted.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    isAttrs
    filterAttrs
    listToAttrs
    nameValuePair
    mapAttrsToList
    ;
  inherit (lib.lists) flatten;
  inherit (lib.modules) mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib.strings) optionalString concatStrings;

  netdevOptions =
    pkgs: netnsName:
    { name, ... }:
    {
      options = {
        kind = mkOption {
          type = types.str;
          description = ''
            Kind of the network device.
          '';
        };
        address = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            Specifies the MAC address to use for the device.
            Leave empty to use the default.
          '';
        };
        mtu = mkOption {
          type = types.nullOr types.int;
          default = null;
          description = ''
            The maximum transmission unit in bytes to set for the device.
            Leave empty to use the default.
          '';
        };
        vrf = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            The name of VRF interface to add the link to.
          '';
        };
        extraArgs = mkOption {
          type = types.submodule {
            freeformType = (pkgs.formats.json { }).type;
          };
          default = { };
          description = ''
            Additional arguments for the netdev type. See {manpage}`ip-link(8)`
            manual page for the details.
          '';
        };
        serviceName = mkOption {
          type = types.str;
          default = "netns-${netnsName}-netdev-${name}.service";
          readOnly = true;
          description = ''
            Systemd service name for the netdev configuration.
          '';
        };
        extraServiceConfig = mkOption {
          type = types.submodule {
            freeformType = (pkgs.formats.json { }).type;
          };
          default = { };
          description = ''
            Additional configuration for the service unit.
          '';
        };
      };
    };

  attrsToString =
    attrs:
    concatStrings (
      mapAttrsToList (
        name: value:
        if isAttrs value then "${name} ${attrsToString value}" else "${name} ${toString value} "
      ) attrs
    );
in
{
  flake.nixosModules.netns =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.netns) mkNetnsOption;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, ... }:
        {
          _file = ./netdevs.nix;

          options = {
            netdevs = mkOption {
              type = types.attrsOf (types.submodule (netdevOptions pkgs name));
              default = { };
              description = ''
                Per-network namespace virtual network devices configuration.

                You can also use systemd-networkd's `netdevs` option. This option
                exists mainly for backward compatibility and for configuring
                features that systemd-networkd does not support.
              '';
            };
          };
        }
      );

      config = {
        systemd.services = listToAttrs (
          flatten (
            mapAttrsToList (
              name: cfg:
              mapAttrsToList (
                n: v:
                nameValuePair "netns-${name}-netdev-${n}" (mkMerge [
                  v.extraServiceConfig
                  {
                    path = with pkgs; [ iproute2 ];
                    script = ''
                      ip link show dev "${n}" >/dev/null 2>&1 && ip link delete dev "${n}"
                      ip link add name "${n}" \
                        ${optionalString (v.address != null) "address ${v.address}"} \
                        ${optionalString (v.mtu != null) "mtu ${toString v.mtu}"} \
                        type "${v.kind}" ${attrsToString v.extraArgs}
                      ${optionalString (v.vrf != null) ''
                        ip link set "${n}" vrf ${v.vrf}
                      ''}
                    '';
                    postStop = ''
                      ip link delete dev "${n}" || true
                    '';
                    serviceConfig = {
                      Type = "oneshot";
                      RemainAfterExit = true;
                      NetworkNamespacePath = cfg.netnsPath;
                    };
                    after = [ "netns-${name}.service" ];
                    partOf = [ "netns-${name}.service" ];
                    wantedBy = [
                      "netns-${name}.service"
                      "multi-user.target"
                    ];
                  }
                ])
              ) cfg.netdevs
            ) enabledNetns
          )
        );
      };
    };
}
