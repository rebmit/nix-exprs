# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{
  self,
  lib,
  getSystem,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (lib.strings) concatStringsSep;
  inherit (self.lib.misc) mkHardenedService;
in
{
  flake.nixosModules.enthalpy =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
    in
    {
      options.services.enthalpy.ipsec = {
        enable = mkEnableOption "IPSec/IKEv2 integration" // {
          default = true;
        };
        organization = mkOption {
          type = types.str;
          description = ''
            Unique identifier of a keypair.
          '';
        };
        commonName = mkOption {
          type = types.str;
          default = config.networking.hostName;
          description = ''
            Name of this node, should be unique within an organization.
          '';
        };
        endpoints = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                serialNumber = mkOption { type = types.str; };
                addressFamily = mkOption { type = types.str; };
                address = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
              };
            }
          );
          description = ''
            List of endpoints available on this node.
          '';
        };
        port = mkOption {
          type = types.port;
          default = 14000;
          description = ''
            UDP port used by the charon daemon for NAT-T traffic.
          '';
        };
        interfaces = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            List of network interfaces that should be used by charon daemon.
          '';
        };
        privateKeyPath = mkOption {
          type = types.str;
          description = ''
            Path to the private key of this organization.
          '';
        };
      };

      config = mkIf (cfg.enable && cfg.ipsec.enable) {
        environment.systemPackages = [ config.services.strongswan-swanctl.package ];

        services.strongswan-swanctl = {
          enable = true;
          strongswan.extraConfig = ''
            charon {
              ikesa_table_size = 32
              ikesa_table_segments = 4
              reuse_ikesa = no
              interfaces_use = ${concatStringsSep "," cfg.ipsec.interfaces}
              port = 0
              port_nat_t = ${toString cfg.ipsec.port}
              retransmit_timeout = 30
              retransmit_base = 1
              plugins {
                socket-default {
                  set_source = yes
                  set_sourceif = yes
                }
                dhcp {
                  load = no
                }
              }
            }
            charon-systemd {
              journal {
                default = -1
              }
            }
          '';
        };

        environment.etc."ranet/config.json".source = (pkgs.formats.json { }).generate "config.json" {
          organization = cfg.ipsec.organization;
          common_name = cfg.ipsec.commonName;
          endpoints = map (ep: {
            serial_number = ep.serialNumber;
            address_family = ep.addressFamily;
            address = ep.address;
            port = cfg.ipsec.port;
            updown = pkgs.writeShellScript "updown" ''
              LINK=enta$(printf '%08x\n' "$PLUTO_IF_ID_OUT")
              case "$PLUTO_VERB" in
                up-client)
                  ip link add "$LINK" type xfrm if_id "$PLUTO_IF_ID_OUT"
                  ip link set "$LINK" netns enthalpy multicast on mtu 1400 up
                  ;;
                down-client)
                  ip -n enthalpy link del "$LINK"
                  ;;
              esac
            '';
          }) cfg.ipsec.endpoints;
        };

        systemd.tmpfiles.rules = [ "d /var/lib/ranet 0750 root root - -" ];

        systemd.services.ranet =
          let
            command = "ranet -c /etc/ranet/config.json -r /var/lib/ranet/registry.json -k ${cfg.ipsec.privateKeyPath}";
          in
          mkHardenedService {
            path = with pkgs; [
              iproute2
              (getSystem pkgs.stdenv.hostPlatform.system).allModuleArgs.self'.packages.ranet
            ];
            script = "${command} up";
            reload = "${command} up";
            preStop = "${command} down";
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            unitConfig = {
              AssertFileNotEmpty = "/var/lib/ranet/registry.json";
            };
            bindsTo = [
              "strongswan-swanctl.service"
            ];
            wants = [
              "network-online.target"
              "strongswan-swanctl.service"
            ];
            after = [
              "network-online.target"
              "netns-enthalpy.service"
              "strongswan-swanctl.service"
            ];
            partOf = [ "netns-enthalpy.service" ];
            wantedBy = [
              "multi-user.target"
              "netns-enthalpy.service"
            ];
            reloadTriggers = [ config.environment.etc."ranet/config.json".source ];
          };
      };
    };
}
