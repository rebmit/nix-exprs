{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) elem;
  inherit (lib.options) mkOption;
  inherit (lib.strings) getName;
in
{
  perSystem = {
    nixpkgs.predicates = {
      allowNonSource = p: elem (getName p) [ "envoy-bin" ];
    };
  };

  flake.unify.modules."services/envoy/common" = {
    nixos = {
      module =
        { config, pkgs, ... }:
        let
          format = pkgs.formats.json { };
          cfg = config.services.envoy;
        in
        {
          options.services.envoy = {
            clusters = mkOption {
              type = types.attrsOf format.type;
              default = { };
              description = ''
                A set of Envoy cluster definitions.
              '';
            };
            listeners = mkOption {
              type = types.attrsOf format.type;
              default = { };
              description = ''
                A set of Envoy listener definitions.
              '';
            };
          };

          config = {
            services.envoy = {
              enable = true;
              package = pkgs.envoy-bin;
              requireValidConfig = false;
              settings = {
                node = {
                  id = config.networking.hostName;
                  cluster = config.networking.domain;
                };
                dynamic_resources = {
                  cds_config.path_config_source = {
                    path = "/etc/envoy/cds.json";
                  };
                  lds_config.path_config_source = {
                    path = "/etc/envoy/lds.json";
                  };
                };
              };
            };

            environment.etc = {
              "envoy/cds.json".source = format.generate "cds.json" {
                resources = mapAttrsToList (n: v: v // { name = n; }) cfg.clusters;
              };
              "envoy/lds.json".source = format.generate "lds.json" {
                resources = mapAttrsToList (n: v: v // { name = n; }) cfg.listeners;
              };
            };
          };
        };
    };
  };
}
