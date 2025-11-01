# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{
  lib,
  withSystem,
  ...
}:
let
  inherit (lib.modules) mkIf mkBefore;
  inherit (lib.options) mkEnableOption;
in
{
  flake.nixosModules.enthalpy =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
    in
    {
      options.services.enthalpy.bird = {
        enable = mkEnableOption "bird integration" // {
          default = true;
        };
      };

      config = mkIf (cfg.enable && cfg.bird.enable) {
        netns.enthalpy = {
          services.bird = {
            enable = true;
            package = withSystem pkgs.stdenv.hostPlatform.system (ps: ps.config.packages.bird2-rebmit);
            config = mkBefore ''
              router id 42;

              protocol device {
                scan time 5;
              }

              ipv6 sadr table sadr6;

              protocol kernel {
                ipv6 sadr {
                  export all;
                  import none;
                };
                metric 512;
              }

              protocol static {
                ipv6 sadr;
                route ${cfg.prefix} from ::/0 unreachable;
              }

              protocol babel {
                ipv6 sadr {
                  export all;
                  import all;
                };
                randomize router id;
                interface "enta*" {
                  type tunnel;
                  link quality etx;
                  rxcost 8;
                  rtt cost 1016;
                  rtt min 8 ms;
                  rtt max 1024 ms;
                  rx buffer 2000;
                };
              }
            '';
          };
        };
      };
    };
}
