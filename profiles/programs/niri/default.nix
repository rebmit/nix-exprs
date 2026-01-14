# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/d40b75ca0955d2a999b36fa1bd0f8b3a6e061ef3/home-manager/profiles/niri/default.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib.lists) range foldr flatten;
  inherit (lib.meta) hiPrio getExe;
  inherit (lib.modules) mkMerge;
  inherit (lib.options) mkOption mkPackageOption;
  inherit (lib.strings)
    hasPrefix
    concatMapAttrsStringSep
    concatStringsSep
    concatMapStringsSep
    ;
  inherit (lib.trivial) boolToString;
  inherit (self.lib.attrsets) flattenTree;
in
{
  flake.unify.modules."programs/niri" = {
    homeManager = {
      meta = {
        tags = [ "desktop" ];
        requires = [
          "programs/firefox"
          "programs/ghostty"
        ];
      };

      module =
        { config, pkgs, ... }:
        let
          cfg = config.programs.niri;
          noctaliaIpc =
            cmd:
            [
              "noctalia-shell"
              "ipc"
              "call"
            ]
            ++ cmd;
        in
        {
          options.programs.niri = {
            package = mkPackageOption pkgs "niri" { };
            binds = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
          };

          config = mkMerge [
            # niri
            {
              xdg.configFile."niri/config.kdl" =
                let
                  windowCornerRadius = 20.0;
                  shadowColor = "#00000050";
                in
                {
                  force = true;
                  source = pkgs.writeText "niri-config.kdl" ''
                    input {
                      keyboard {
                        repeat-delay 600
                        repeat-rate 25
                        track-layout "global"
                      }
                      touchpad {
                        tap
                        dwt
                        natural-scroll
                      }
                    }

                    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

                    prefer-no-csd

                    hotkey-overlay { skip-at-startup; }

                    layout {
                      gaps 12
                      struts {
                        left 0
                        right 0
                        top 0
                        bottom 0
                      }
                      focus-ring {
                        width 3
                      }
                      border { off; }
                      shadow {
                        on
                        offset x=0 y=0
                        softness 8
                        spread 5
                        draw-behind-window true
                        color "${shadowColor}"
                        inactive-color "${shadowColor}"
                      }
                      tab-indicator {
                        place-within-column
                        gap 5
                        width 6
                        length total-proportion=0.5
                        position "left"
                        gaps-between-tabs 8
                        corner-radius 3
                      }
                      default-column-width { proportion 0.500000; }
                      preset-column-widths {
                        proportion 0.333333
                        proportion 0.500000
                        proportion 0.666667
                      }
                      center-focused-column "never"
                    }

                    recent-windows {
                      highlight {
                        padding 30
                        corner-radius ${toString windowCornerRadius}
                      }

                      binds {
                        Alt+Tab         { next-window; }
                        Alt+Shift+Tab   { previous-window; }
                        Alt+grave       { next-window     filter="app-id"; }
                        Alt+Shift+grave { previous-window filter="app-id"; }
                      }
                    }

                    window-rule {
                      geometry-corner-radius ${toString windowCornerRadius}
                      clip-to-geometry true
                    }

                    window-rule {
                      match app-id="^nheko$"
                      match app-id="^org.telegram.desktop$"
                      block-out-from "screencast"
                    }

                    layer-rule {
                      match namespace="^noctalia-overview*"
                      place-within-backdrop true
                    }

                    binds {
                      ${concatStringsSep "\n  " cfg.binds}
                    }

                    debug {
                      honor-xdg-activation-with-invalid-serial
                    }

                    cursor {
                      xcursor-theme "capitaine-cursors"
                      xcursor-size 36
                    }

                    include "noctalia.kdl"
                  '';
                };

              systemd.user.tmpfiles.rules = [
                "f %h/.config/niri/noctalia.kdl - - - -"
              ];

              programs.niri.binds =
                let
                  modMove = "Shift";
                  modMonitor = "Ctrl";
                  keyUp = "K";
                  keyDown = "J";
                  keyLeft = "H";
                  keyRight = "L";
                  directions = {
                    left = {
                      keys = [
                        "Left"
                        keyLeft
                        "WheelScrollLeft"
                      ];
                      windowTerm = "column";
                    };
                    down = {
                      keys = [
                        "Down"
                        keyDown
                      ];
                      windowTerm = "window";
                    };
                    up = {
                      keys = [
                        "Up"
                        keyUp
                      ];
                      windowTerm = "window";
                    };
                    right = {
                      keys = [
                        "Right"
                        keyRight
                        "WheelScrollRight"
                      ];
                      windowTerm = "column";
                    };
                  };
                  workspaceDirections = {
                    up = {
                      keys = [
                        "Page_Up"
                        "WheelScrollUp"
                      ];
                    };
                    down = {
                      keys = [
                        "Page_Down"
                        "WheelScrollDown"
                      ];
                    };
                  };
                  workspaceIndices = range 1 9;
                  isWheelKey = hasPrefix "Wheel";
                  wheelCooldownMs = 100;
                  windowBindings = mapAttrsToList (
                    direction: cfg:
                    (map (
                      key:
                      let
                        cooldown = if (isWheelKey key) then "cooldown-ms=${toString wheelCooldownMs} " else "";
                      in
                      [
                        "Mod+${key} ${cooldown}{ focus-${cfg.windowTerm}-${direction}; }"
                        "Mod+${modMove}+${key} ${cooldown}{ move-${cfg.windowTerm}-${direction}; }"
                        "Mod+${modMonitor}+${key} ${cooldown}{ focus-monitor-${direction}; }"
                        "Mod+${modMove}+${modMonitor}+${key} ${cooldown}{ move-column-to-monitor-${direction}; }"
                      ]
                    ) cfg.keys)
                  ) directions;
                  workspaceBindings = mapAttrsToList (
                    direction: cfg:
                    (map (
                      key:
                      let
                        cooldown = if (isWheelKey key) then "cooldown-ms=${toString wheelCooldownMs} " else "";
                      in
                      [
                        "Mod+${key} ${cooldown}{ focus-workspace-${direction}; }"
                        "Mod+${modMove}+${key} ${cooldown}{ move-column-to-workspace-${direction}; }"
                        "Mod+Ctrl+${key} ${cooldown}{ move-workspace-${direction}; }"
                      ]
                    ) cfg.keys)
                  ) workspaceDirections;
                  indexedWorkspaceBindings = map (index: [
                    "Mod+${toString index} { focus-workspace ${toString index}; }"
                    "Mod+${modMove}+${toString index} { move-column-to-workspace ${toString index}; }"
                  ]) workspaceIndices;
                  specialBindings =
                    let
                      spawn = command: "spawn ${concatMapStringsSep " " (s: "\"${s}\"") command}";
                    in
                    [
                      "Mod+W      repeat=false { ${spawn [ "firefox" ]}; }"
                      "Mod+Return repeat=false { ${spawn [ "ghostty" ]}; }"
                      "Mod+D      repeat=false { ${
                        spawn (noctaliaIpc [
                          "launcher"
                          "toggle"
                        ])
                      }; }"
                      "Mod+V      repeat=false { ${
                        spawn (noctaliaIpc [
                          "launcher"
                          "clipboard"
                        ])
                      }; }"
                      "Mod+M      repeat=false { ${
                        spawn (noctaliaIpc [
                          "lockScreen"
                          "lock"
                        ])
                      }; }"
                      "XF86AudioRaiseVolume allow-when-locked=true { ${
                        spawn (noctaliaIpc [
                          "volume"
                          "increase"
                        ])
                      }; }"
                      "XF86AudioLowerVolume allow-when-locked=true { ${
                        spawn (noctaliaIpc [
                          "volume"
                          "decrease"
                        ])
                      }; }"
                      "XF86AudioMute        allow-when-locked=true { ${
                        spawn (noctaliaIpc [
                          "volume"
                          "muteOutput"
                        ])
                      }; }"
                      "XF86AudioMicMute     allow-when-locked=true { ${
                        spawn (noctaliaIpc [
                          "volume"
                          "muteInput"
                        ])
                      }; }"
                      "Mod+P { ${
                        spawn (noctaliaIpc [
                          "media"
                          "playPause"
                        ])
                      }; }"
                      "Mod+I { ${
                        spawn (noctaliaIpc [
                          "media"
                          "previous"
                        ])
                      }; }"
                      "Mod+O { ${
                        spawn (noctaliaIpc [
                          "media"
                          "next"
                        ])
                      }; }"
                      "Mod+Shift+Q { close-window; }"
                      "Mod+Tab { focus-workspace-previous; }"
                      "Mod+C { center-column; }"
                      "Mod+Comma        { consume-window-into-column; }"
                      "Mod+Period       { expel-window-from-column; }"
                      "Mod+BracketLeft  { consume-or-expel-window-left; }"
                      "Mod+BracketRight { consume-or-expel-window-right; }"
                      "Mod+R { switch-preset-column-width; }"
                      "Mod+Shift+R { reset-window-height; }"
                      "Mod+F { maximize-column; }"
                      "Mod+Shift+F { fullscreen-window; }"
                      "Mod+Minus { set-column-width \"-10%\"; }"
                      "Mod+Equal { set-column-width \"+10%\"; }"
                      "Mod+Shift+Minus { set-window-height \"-10%\"; }"
                      "Mod+Shift+Equal { set-window-height \"+10%\"; }"
                      "Mod+Shift+S { screenshot; }"
                      "Mod+Ctrl+S { screenshot-window; }"
                      "Mod+Shift+E { quit; }"
                      "Mod+Z { toggle-overview; }"
                    ];
                in
                flatten [
                  specialBindings
                  workspaceBindings
                  indexedWorkspaceBindings
                  windowBindings
                ];

              home.packages = with pkgs; [
                (hiPrio (writeShellApplication {
                  name = "wayland-session";
                  runtimeInputs = [ cfg.package ];
                  text = ''
                    niri-session
                  '';
                }))

                cfg.package
                wl-clipboard
              ];
            }

            # noctalia
            (
              let
                inherit (pkgs) noctalia-shell;

                toggleDarkMode = pkgs.writeShellApplication {
                  name = "noctalia-toggle-dark-mode";
                  runtimeInputs = [
                    config.services.darkman.package
                  ];
                  text = ''
                    if [ "$1" = "true" ]; then
                      mode="dark"
                    else
                      mode="light"
                    fi
                    darkman set "$mode"
                  '';
                };

                syncSettings = pkgs.writeShellApplication {
                  name = "noctalia-sync-settings";
                  runtimeInputs = with pkgs; [
                    jq
                  ];
                  text = ''
                    path="profiles/programs/niri/noctalia-base-settings.json"
                    full_path="$PRJ_ROOT/$path"
                    echo "writing to '$full_path'..."
                    jq 'del(
                      ${concatMapAttrsStringSep ",\n  " (name: _value: ".${name}") (
                        flattenTree {
                          separator = ".";
                          mapper = x: "\"${x}\"";
                        } specialSettings
                      )}
                    )' ~/.config/noctalia/gui-settings.json >"$full_path"
                    nix fmt

                    echo "git diff..."
                    git diff -- "$path"

                    echo "checking path leaking..."
                    jq 'pick(.. | select(type == "string" and contains("/")))' "$full_path"
                  '';
                };

                specialSettings = {
                  hooks = {
                    enabled = true;
                    darkModeChange = "${getExe toggleDarkMode} $1";
                  };
                };
              in
              {
                xdg.configFile."noctalia/settings.json" =
                  let
                    settings = foldr recursiveUpdate { } [
                      (builtins.fromJSON (builtins.readFile ./noctalia-base-settings.json))
                      specialSettings
                    ];
                  in
                  {
                    force = true;
                    source = (pkgs.formats.json { }).generate "noctalia-settings.json" settings;
                  };

                home.packages = with pkgs; [
                  noctalia-shell
                  pwvucontrol
                  cliphist
                  syncSettings
                ];

                systemd.user.services.noctalia-shell = {
                  Unit = {
                    Description = "Noctalia Shell - Wayland desktop shell";
                    Documentation = "https://docs.noctalia.dev/docs";
                    After = [ "graphical-session.target" ];
                    Requisite = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                    X-Restart-Triggers = [ config.xdg.configFile."noctalia/settings.json".source ];
                  };

                  Service = {
                    ExecStart = getExe noctalia-shell;
                    Restart = "on-failure";
                    Environment = [
                      "QT_QPA_PLATFORMTHEME=gtk3"
                      "NOCTALIA_SETTINGS_FALLBACK=%h/.config/noctalia/gui-settings.json"
                    ];
                  };

                  Install.WantedBy = [ "graphical-session.target" ];
                };

                services.darkman =
                  let
                    mkScript =
                      mode:
                      let
                        inherit (config.theme.${mode}) wallpaper;
                      in
                      pkgs.writeShellApplication {
                        name = "darkman-switch-noctalia-${mode}";
                        text = ''
                          noctalia-shell ipc call wallpaper set ${wallpaper} all

                          dark_mode=$(noctalia-shell ipc call state all | jq -r '.settings.colorSchemes.darkMode')

                          if [[ "$dark_mode" != ${boolToString (mode == "dark")} ]]; then
                            noctalia-shell ipc call darkMode ${if mode == "dark" then "setDark" else "setLight"}
                          fi
                        '';
                      };
                  in
                  {
                    lightModeScripts.noctalia = "${getExe (mkScript "light")}";
                    darkModeScripts.noctalia = "${getExe (mkScript "dark")}";
                  };
              }
            )

            # kanshi
            {
              home.packages = with pkgs; [
                wdisplays
              ];

              services.kanshi.enable = true;
            }

            # xdg-desktop-portal
            {
              xdg.portal = {
                enable = true;
                extraPortals = with pkgs; [
                  xdg-desktop-portal-gtk
                  xdg-desktop-portal-gnome
                ];
                config.niri = {
                  "default" = [
                    "gnome"
                    "gtk"
                  ];
                  "org.freedesktop.impl.portal.Access" = [ "gtk" ];
                  "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
                };
                xdgOpenUsePortal = true;
              };

              home.packages = with pkgs; [
                xdg-utils
              ];
            }

            # polkit agent
            {
              systemd.user.services.niri-polkit-agent = {
                Unit = {
                  Description = "PolicyKit Agent for Niri";
                  After = [ "graphical-session.target" ];
                  Requisite = [ "graphical-session.target" ];
                  PartOf = [ "graphical-session.target" ];
                };
                Service = {
                  ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                  RestartSec = 5;
                  Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
              };
            }
          ];
        };
    };
  };
}
