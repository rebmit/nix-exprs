# Portions of this file are sourced from
# https://github.com/stepbrobd/dotfiles/blob/191964582ffbc5a2cec018aa510ebe920b56f6f8/modules/nixos/as10779.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.lists) optionals;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) concatMapStringsSep optionalString;
in
{
  flake.modules.nixos."services/as212982" =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.services.as212982;

      routeType = types.submodule {
        options = {
          prefix = mkOption {
            type = types.str;
            description = ''
              Network prefix announced by the static protocol.
            '';
          };
          option = mkOption {
            type = types.str;
            description = ''
              Route attributes passed to the BIRD static route declaration.
            '';
          };
        };
      };

      decisionType = types.submodule {
        options = {
          interface = {
            local = mkOption {
              type = types.str;
              description = ''
                Name of the local interface.
              '';
            };
          };

          ipv6.addresses = mkOption {
            type = types.listOf types.str;
            description = ''
              IPv6 addresses assigned to the local interface.
            '';
          };
        };
      };
    in
    {
      options.services.as212982 = {
        enable = mkEnableOption "as212982";

        asn = mkOption {
          type = types.int;
          default = 212982;
          description = ''
            Local autonomous system number (ASN).
          '';
        };

        local = mkOption {
          type = decisionType;
          description = ''
            Local interface and routing configuration.
          '';
        };

        router = {
          id = mkOption {
            type = types.str;
            description = ''
              BIRD router ID.
            '';
          };

          exit = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this node acts as an edge router and establishes external BGP sessions.
            '';
          };

          scantime = mkOption {
            type = types.int;
            default = 5;
            description = ''
              Interval in seconds between scans of network interfaces.
            '';
          };

          includes = mkOption {
            type = types.listOf types.path;
            default = [ ];
            description = ''
              Paths to external BIRD configuration files included via the `include` directive.
            '';
          };

          source = {
            ipv6 = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                Default IPv6 source address used for outbound BGP sessions.
              '';
            };
          };

          rpki = {
            ipv6 = {
              table = mkOption {
                type = types.str;
                default = "trpki6";
                description = ''
                  Name of the IPv6 RPKI ROA table.
                '';
              };
              filter = mkOption {
                type = types.str;
                default = "validated6";
                description = ''
                  Name of the IPv6 RPKI validation filter.
                '';
              };
            };
            retry = mkOption {
              type = types.int;
              default = 600;
              description = ''
                Time in seconds between retry attempts after a failed Serial/Reset Query.
              '';
            };
            refresh = mkOption {
              type = types.int;
              default = 3600;
              description = ''
                Time period in seconds. Tells how long to wait before next attempting to poll
                the cache using a Serial Query or a Reset Query packet.
              '';
            };
            expire = mkOption {
              type = types.int;
              default = 7200;
              description = ''
                Time period in seconds. Received records are deleted if the client was unable
                to successfully refresh data for this time period.
              '';
            };
            validators = mkOption {
              type = types.listOf (
                types.submodule {
                  options = {
                    id = mkOption {
                      type = types.int;
                      description = ''
                        Unique identifier used to generate protocol instance names.
                      '';
                    };
                    remote = mkOption {
                      type = types.str;
                      description = ''
                        Full domain name or IP address of the RPKI cache server.
                      '';
                    };
                    port = mkOption {
                      type = types.int;
                      description = ''
                        TCP port of the RPKI cache server.
                      '';
                    };
                  };
                }
              );
              default = [
                {
                  id = 0;
                  remote = "rtr.rpki.cloudflare.com";
                  port = 8282;
                }
              ];
              description = ''
                List of RPKI RTR validators.
              '';
            };
          };

          device.name = mkOption {
            type = types.str;
            default = "device0";
            description = ''
              Name of the BIRD device protocol instance.
            '';
          };

          kernel = {
            ipv6 = {
              name = mkOption {
                type = types.str;
                default = "kernel6";
                description = ''
                  Name of the IPv6 kernel protocol instance.
                '';
              };
              import = mkOption {
                type = types.str;
                default = "import none;";
                description = ''
                  IPv6 import policy for the kernel protocol.
                '';
              };
              export = mkOption {
                type = types.str;
                default = "export none;";
                description = ''
                  IPv6 export policy for the kernel protocol.
                '';
              };
            };
          };

          static = {
            ipv6 = {
              name = mkOption {
                type = types.str;
                default = "static6";
                description = ''
                  Name of the IPv6 static protocol instance.
                '';
              };
              routes = mkOption {
                type = types.listOf routeType;
                description = ''
                  List of IPv6 static routes to be announced.
                '';
              };
            };
          };

          sessions = mkOption {
            type = types.listOf (
              types.submodule {
                options = {
                  name = mkOption {
                    type = types.str;
                    description = ''
                      Name of the BGP session.
                    '';
                  };

                  password = mkOption {
                    type = types.nullOr types.str;
                    description = ''
                      Variable name referencing the BGP session password.
                    '';
                  };

                  type = {
                    ipv6 = mkOption {
                      type = types.enum [
                        "disabled"
                        "direct"
                        "multihop"
                      ];
                      description = ''
                        IPv6 BGP session type.
                      '';
                    };
                  };

                  multihop = {
                    ipv6 = mkOption {
                      type = types.nullOr types.int;
                      default = null;
                      description = ''
                        Maximum hop count for IPv6 multihop BGP sessions.
                      '';
                    };
                  };

                  source = {
                    ipv6 = mkOption {
                      type = types.nullOr types.str;
                      default = cfg.router.source.ipv6;
                      description = ''
                        IPv6 source address used for this BGP session.
                      '';
                    };
                  };

                  neighbor = {
                    asn = mkOption {
                      type = types.int;
                      description = ''
                        Autonomous system number of the BGP neighbor.
                      '';
                    };
                    ipv6 = mkOption {
                      type = types.nullOr types.str;
                      default = null;
                      description = ''
                        IPv6 address of the BGP neighbor.
                      '';
                    };
                  };

                  addpath = mkOption {
                    type = types.enum [
                      "switch"
                      "rx"
                      "tx"
                      "off"
                    ];
                    default = "off";
                    description = ''
                      BGP Add-Path capability mode.
                    '';
                  };

                  import = {
                    ipv6 = mkOption {
                      type = types.str;
                      default = "import none;";
                      description = ''
                        IPv6 import policy for this BGP session.
                      '';
                    };
                  };

                  export = {
                    ipv6 = mkOption {
                      type = types.str;
                      default = "export none;";
                      description = ''
                        IPv6 export policy for this BGP session.
                      '';
                    };
                  };
                };
              }
            );
            description = ''
              List of BGP sessions configured on this router.
            '';
          };
        };
      };

      config = mkIf cfg.enable (mkMerge [
        {
          systemd.network.config.networkConfig.ManageForeignRoutes = false;

          systemd.network.netdevs = {
            "40-${cfg.local.interface.local}" = {
              netdevConfig = {
                Kind = "dummy";
                Name = cfg.local.interface.local;
              };
            };
          };

          systemd.network.networks = {
            "40-${cfg.local.interface.local}" = {
              name = cfg.local.interface.local;
              address = cfg.local.ipv6.addresses;
            };
          };
        }
        {
          networking.firewall.allowedTCPPorts = optionals cfg.router.exit [ 179 ];

          services.bird = {
            enable = cfg.router.exit;
            package = pkgs.bird3;
            checkConfig = false;
            config = ''
              ${concatMapStringsSep "\n" (file: ''
                include "${file}";
              '') cfg.router.includes}

              router id ${cfg.router.id};

              roa6 table ${cfg.router.rpki.ipv6.table};

              ${concatMapStringsSep "\n\n" (validator: ''
                protocol rpki rpki${toString validator.id} {
                  roa6 { table ${cfg.router.rpki.ipv6.table}; };

                  remote "${validator.remote}" port ${toString validator.port};

                  retry keep ${toString cfg.router.rpki.retry};
                  refresh keep ${toString cfg.router.rpki.refresh};
                  expire ${toString cfg.router.rpki.expire};
                }
              '') cfg.router.rpki.validators}

              filter ${cfg.router.rpki.ipv6.filter} {
                if (roa_check(${cfg.router.rpki.ipv6.table}, net, bgp_path.last) = ROA_INVALID) then {
                  print "Ignore RPKI invalid ", net, " for ASN ", bgp_path.last;
                  reject;
                }
                accept;
              }

              protocol device ${cfg.router.device.name} {
                scan time ${toString cfg.router.scantime};
              }

              protocol kernel ${cfg.router.kernel.ipv6.name} {
                scan time ${toString cfg.router.scantime};

                learn;
                persist;

                ipv6 {
                  ${cfg.router.kernel.ipv6.import}
                  ${cfg.router.kernel.ipv6.export}
                };
              }

              protocol static ${cfg.router.static.ipv6.name} {
                ipv6;

                ${concatMapStringsSep "\n  " (
                  r: ''route ${r.prefix} ${r.option};''
                ) cfg.router.static.ipv6.routes}
              }

              ${concatMapStringsSep "\n\n" (
                session:
                optionalString (session.type.ipv6 != "disabled") ''
                  protocol bgp ${session.name}6 {
                    graceful restart on;

                    ${
                      if session.type.ipv6 == "multihop" && session.multihop.ipv6 != null then
                        "multihop ${toString session.multihop.ipv6}"
                      else
                        "${session.type.ipv6}"
                    };
                    ${if (isNull session.source.ipv6) then "" else ''source address ${session.source.ipv6};''}
                    local as ${toString cfg.asn};
                    neighbor ${session.neighbor.ipv6} as ${toString session.neighbor.asn};${
                      if isNull session.password then "" else "\n  password ${session.password};"
                    }

                    ipv6 {
                      add paths ${session.addpath};
                      ${session.import.ipv6}
                      ${session.export.ipv6}
                    };
                  }
                ''
              ) cfg.router.sessions}
            '';
          };
        }
      ]);
    };
}
