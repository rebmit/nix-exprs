# Portions of this file are sourced from
# https://github.com/nix-community/home-manager/blob/ce76393bb74b6a4bbe02e30e9bd01e9839dc377c/nixos/common.nix (MIT License)
# https://github.com/nix-community/home-manager/blob/ce76393bb74b6a4bbe02e30e9bd01e9839dc377c/nixos/default.nix (MIT License)
{
  inputs,
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.attrsets)
    optionalAttrs
    attrNames
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) flatten;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types)
    submoduleWith
    raw
    lazyAttrsOf
    submodule
    listOf
    str
    deferredModule
    attrsOf
    attrs
    ;
  inherit (lib.trivial) flip;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  homeManagerModule =
    {
      home-manager,
      name,
      options,
      config,
      pkgs,
      _class,
      specialArgs,
      useGlobalPkgs,
      useUserPackages,
      ...
    }:
    let
      extendedLib = import "${home-manager}/modules/lib/stdlib-extended.nix" lib;
    in
    submoduleWith {
      description = "Home Manager module";
      class = "homeManager";
      specialArgs = {
        lib = extendedLib;
        osConfig = config;
        osClass = _class;
        modulesPath = toString "${home-manager}/modules";
      }
      // specialArgs;

      modules = [
        (
          { ... }:
          {
            imports = import "${home-manager}/modules/modules.nix" {
              inherit pkgs;
              lib = extendedLib;
              useNixpkgsModule = !useGlobalPkgs;
            };

            config = {
              submoduleSupport.enable = true;
              submoduleSupport.externalPackageInstall = useUserPackages;

              home.username = config.users.users.${name}.name;
              home.homeDirectory = config.users.users.${name}.home;

              # Forward `nix.enable` from the OS configuration. The
              # conditional is to check whether nix-darwin is new enough
              # to have the `nix.enable` option; it was previously a
              # `mkRemovedOptionModule` error, which we can crudely detect
              # by `visible` being set to `false`.
              nix.enable = mkIf (options.nix.enable.visible or true) config.nix.enable;

              # Make activation script use same version of Nix as system as a whole.
              # This avoids problems with Nix not being in PATH.
              nix.package = config.nix.package;
            };
          }
        )
      ];
    };

  unifyHomeManagerOption =
    {
      standalone ? true,
      system ? null,
    }:
    mkOption {
      type = lazyAttrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              meta = mkOption {
                type = submodule {
                  freeformType = mkStructuredType { typeName = "meta"; };
                  options = {
                    includes = mkOption {
                      type = listOf str;
                      default = [ ];
                      description = ''
                        A list of additional modules to import explicitly.  All modules listed here,
                        along with their dependency closures, will be automatically imported.
                      '';
                    };
                    excludes = mkOption {
                      type = listOf str;
                      default = [ ];
                      description = ''
                        A list of modules to exclude.  Any module listed here will be removed from the
                        dependency closure, even if it would otherwise be imported.
                      '';
                    };
                  };
                };
                default = { };
                description = ''
                  Metadata for this home-manager configuration.
                '';
              };
              name = mkOption {
                type = str;
                default = name;
                readOnly = !standalone;
                description = ''
                  The name of this home-manager configuration.
                '';
              };
              system = mkOption {
                type = str;
                default = system;
                readOnly = !standalone;
                description = ''
                  The system for this home-manager configuration.
                '';
              };
              module = mkOption {
                type = deferredModule;
                default = { };
                description = ''
                  The deferred module for this home-manager configuration.
                '';
              };
              home-manager = mkOption {
                type = raw;
                default = inputs.home-manager or (throw "cannot find home-manager input");
                description = ''
                  The home-manager flake to be used for evaluate home-manager configuration.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = ''
        A set of home-manager configurations.
      '';
    };

  systemHomeManagerModule =
    cfg:
    { pkgs, ... }@nixos:
    {
      options.users.users = mkOption {
        type = attrsOf (
          submodule (
            { name, config, ... }:
            let
              hmCfg = config.home-manager;

              closure = self.unify.lib.collectModulesForConfig "homeManager" {
                inherit (cfg.${name}) name;
                inherit (cfg.${name}.meta) includes excludes;
              };

              unify = cfg.${name};
            in
            {
              options.home-manager = mkOption {
                type = submodule {
                  options = optionalAttrs (cfg ? ${name}) {
                    useUserPackages =
                      mkEnableOption ''
                        installation of user packages through the
                        {option}`users.users.<name>.packages` option
                      ''
                      // {
                        default = true;
                      };
                    useGlobalPkgs =
                      mkEnableOption ''
                        using the system configuration's `pkgs`
                        argument in Home Manager. This disables the Home Manager
                        options {option}`nixpkgs.*`
                      ''
                      // {
                        default = true;
                      };
                    specialArgs = mkOption {
                      type = attrs;
                      default = { };
                      description = ''
                        Per-user specialArgs passed to Home Manager.
                      '';
                    };
                    module = mkOption {
                      type = homeManagerModule {
                        inherit (cfg.${name}) home-manager;
                        inherit name;
                        inherit pkgs;
                        inherit (nixos)
                          options
                          config
                          _class
                          ;
                        inherit (hmCfg) specialArgs useGlobalPkgs useUserPackages;
                      };
                      visible = "shallow";
                      description = ''
                        Per-user Home Manager module.
                      '';
                    };
                  };

                  config = optionalAttrs (cfg ? ${name}) {
                    specialArgs = {
                      nixosConfig = nixos.config;
                      inherit (nixos) self inputs;
                      inherit unify;
                    };

                    module = _: {
                      imports = [
                        cfg.${name}.module
                      ]
                      ++ map (n: self.unify.modules.${n}.homeManager.module) closure;

                      key = "home-manager#nixos-shared-module";

                      config = {
                        fonts.fontconfig.enable = mkDefault (hmCfg.useUserPackages && nixos.config.fonts.fontconfig.enable);
                        i18n.glibcLocales = mkDefault nixos.config.i18n.glibcLocales;
                        home.stateVersion = mkDefault nixos.config.system.stateVersion;
                      };
                    };
                  };
                };
                default = { };
                description = ''
                  Per-user Home Manager configuration.
                '';
              };

              config = {
                packages = mkIf (hmCfg ? useUserPackages && hmCfg.useUserPackages) [ hmCfg.module.home.path ];
              };
            }
          )
        );
      };
    };
in
{
  options.flake = mkSubmoduleOptions {
    unify.configs.nixos = mkOption {
      type = lazyAttrsOf (
        submodule (
          { config, ... }:
          let
            cfg = config.submodules.home-manager.users;
          in
          {
            options.submodules.home-manager.users = unifyHomeManagerOption {
              standalone = false;
              system = config.system;
            };

            config = {
              module =
                {
                  config,
                  pkgs,
                  utils,
                  ...
                }:
                let
                  hmCfg = name: config.users.users.${name}.home-manager;
                in
                {
                  imports = [ (systemHomeManagerModule cfg) ];

                  warnings = flatten (
                    flip map (attrNames cfg) (
                      n: flip map (hmCfg n).module.warnings (warning: "${n} profile: ${warning}")
                    )
                  );

                  assertions = flatten (
                    flip map (attrNames cfg) (
                      n:
                      flip map (hmCfg n).module.assertions (assertion: {
                        inherit (assertion) assertion;
                        message = "${n} profile}: ${assertion.message}";
                      })
                    )
                  );

                  environment.pathsToLink = [ "/etc/profile.d" ];

                  systemd.services = mapAttrs' (
                    n: _:
                    let
                      usercfg = hmCfg n;
                      username = usercfg.module.home.username;
                      driverVersion = "1";
                    in
                    nameValuePair "home-manager-${utils.escapeSystemdPath username}" {
                      description = "Home Manager environment for ${username}";
                      wantedBy = [ "multi-user.target" ];
                      wants = [ "nix-daemon.socket" ];
                      after = [ "nix-daemon.socket" ];
                      before = [ "systemd-user-sessions.service" ];
                      unitConfig = {
                        RequiresMountsFor = usercfg.module.home.homeDirectory;
                      };

                      stopIfChanged = false;

                      serviceConfig = {
                        User = usercfg.module.home.username;
                        Type = "oneshot";
                        TimeoutStartSec = "5m";
                        SyslogIdentifier = "hm-activate-${username}";

                        ExecStart =
                          let
                            systemctl = "XDG_RUNTIME_DIR=\${XDG_RUNTIME_DIR:-/run/user/$UID} systemctl";

                            sed = "${pkgs.gnused}/bin/sed";

                            exportedSystemdVariables = lib.concatStringsSep "|" [
                              "DBUS_SESSION_BUS_ADDRESS"
                              "DISPLAY"
                              "WAYLAND_DISPLAY"
                              "XAUTHORITY"
                              "XDG_RUNTIME_DIR"
                            ];

                            setupEnv = pkgs.writeScript "hm-setup-env" ''
                              #! ${pkgs.runtimeShell} -el

                              # The activation script is run by a login shell to make sure
                              # that the user is given a sane environment.
                              # If the user is logged in, import variables from their current
                              # session environment.
                              eval "$(
                                ${systemctl} --user show-environment 2> /dev/null \
                                | ${sed} -En '/^(${exportedSystemdVariables})=/s/^/export /p'
                              )"

                              exec "$1/activate" --driver-version ${driverVersion}
                            '';
                          in
                          "${setupEnv} ${usercfg.module.home.activationPackage}";
                      };
                    }
                  ) cfg;
                };
            };
          }
        )
      );
    };
  };
}
