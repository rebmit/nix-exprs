# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/d40b75ca0955d2a999b36fa1bd0f8b3a6e061ef3/home-manager/profiles/niri/default.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib.attrsets) mapAttrsToList recursiveUpdate;
  inherit (lib.lists)
    singleton
    range
    concatLists
    foldr
    ;
  inherit (lib.meta) hiPrio getExe;
  inherit (lib.modules) mkMerge mkIf;
  inherit (lib.strings) hasPrefix concatMapAttrsStringSep;
  inherit (lib.trivial) boolToString;
  inherit (self.lib.attrsets) flattenTree;
in
{
  flake.unify.modules."programs/niri" = {
    homeManager = {
      meta = {
        tags = [ "desktop" ];
        requires = [
          "imports/niri-flake"
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
          config = mkMerge [
            # niri
            {
              programs.niri = {
                package = pkgs.niri;
                settings = {
                  input = {
                    touchpad = {
                      tap = true;
                      natural-scroll = true;
                      dwt = true;
                    };
                  };
                  layout = {
                    gaps = 8;
                    center-focused-column = "never";
                    preset-column-widths = [
                      { proportion = 1.0 / 3.0; }
                      { proportion = 1.0 / 2.0; }
                      { proportion = 2.0 / 3.0; }
                    ];
                    default-column-width = {
                      proportion = 1.0 / 2.0;
                    };
                    focus-ring = {
                      enable = true;
                      width = 4;
                      active.color = "#7fc8ff";
                      inactive.color = "#505050";
                    };
                    border = {
                      enable = false;
                      width = 4;
                      active.color = "#ffc87f";
                      inactive.color = "#505050";
                    };
                    struts = { };
                  };
                  hotkey-overlay = {
                    skip-at-startup = true;
                  };
                  spawn-at-startup = [ ];
                  prefer-no-csd = true;
                  screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
                  animations.enable = true;
                  window-rules = [
                    {
                      geometry-corner-radius =
                        let
                          radius = 20.0;
                        in
                        {
                          bottom-left = radius;
                          bottom-right = radius;
                          top-left = radius;
                          top-right = radius;
                        };
                      clip-to-geometry = true;
                    }
                  ];
                  debug = {
                    honor-xdg-activation-with-invalid-serial = [ ];
                  };
                  binds =
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
                            keyLeft
                            "WheelScrollLeft"
                          ];
                          windowTerm = "column";
                        };
                        down = {
                          keys = singleton keyDown;
                          windowTerm = "window";
                        };
                        up = {
                          keys = singleton keyUp;
                          windowTerm = "window";
                        };
                        right = {
                          keys = [
                            keyRight
                            "WheelScrollRight"
                          ];
                          windowTerm = "column";
                        };
                      };
                      workspaceIndices = range 1 9;
                      isWheelKey = hasPrefix "Wheel";
                      wheelCooldownMs = 100;
                      windowBindings = mkMerge (
                        concatLists (
                          mapAttrsToList (
                            direction: cfg:
                            (map (
                              key:
                              let
                                cooldown-ms = mkIf (isWheelKey key) wheelCooldownMs;
                              in
                              {
                                "Mod+${key}" = {
                                  action."focus-${cfg.windowTerm}-${direction}" = [ ];
                                  inherit cooldown-ms;
                                };
                                "Mod+${modMove}+${key}" = {
                                  action."move-${cfg.windowTerm}-${direction}" = [ ];
                                  inherit cooldown-ms;
                                };
                                "Mod+${modMonitor}+${key}" = {
                                  action."focus-monitor-${direction}" = [ ];
                                  inherit cooldown-ms;
                                };
                                "Mod+${modMove}+${modMonitor}+${key}" = {
                                  action."move-column-to-monitor-${direction}" = [ ];
                                  inherit cooldown-ms;
                                };
                              }
                            ) cfg.keys)
                          ) directions
                        )
                      );
                      indexedWorkspaceBindings = mkMerge (
                        map (index: {
                          "Mod+${toString index}" = {
                            action.focus-workspace = [ index ];
                          };
                          "Mod+${modMove}+${toString index}" = {
                            action.move-column-to-workspace = [ index ];
                          };
                        }) workspaceIndices
                      );
                      specialBindings = {
                        "Mod+W".action.spawn = [ "firefox" ];
                        "Mod+Return".action.spawn = [ "ghostty" ];
                        "Mod+D".action.spawn = noctaliaIpc [
                          "launcher"
                          "toggle"
                        ];
                        "Mod+M".action.spawn = noctaliaIpc [
                          "lockScreen"
                          "lock"
                        ];
                        "Mod+V".action.spawn = noctaliaIpc [
                          "launcher"
                          "clipboard"
                        ];
                        "XF86AudioRaiseVolume" = {
                          allow-when-locked = true;
                          action.spawn = noctaliaIpc [
                            "volume"
                            "increase"
                          ];
                        };
                        "XF86AudioLowerVolume" = {
                          allow-when-locked = true;
                          action.spawn = noctaliaIpc [
                            "volume"
                            "decrease"
                          ];
                        };
                        "XF86AudioMute" = {
                          allow-when-locked = true;
                          action.spawn = noctaliaIpc [
                            "volume"
                            "muteOutput"
                          ];
                        };
                        "XF86AudioMicMute" = {
                          allow-when-locked = true;
                          action.spawn = noctaliaIpc [
                            "volume"
                            "muteInput"
                          ];
                        };
                        "Mod+P".action.spawn = noctaliaIpc [
                          "media"
                          "playPause"
                        ];
                        "Mod+I".action.spawn = noctaliaIpc [
                          "media"
                          "previous"
                        ];
                        "Mod+O".action.spawn = noctaliaIpc [
                          "media"
                          "next"
                        ];
                        "Mod+Shift+Q".action.close-window = [ ];
                        "Mod+Tab".action.focus-workspace-previous = [ ];
                        "Mod+C".action.center-column = [ ];
                        "Mod+Comma".action.consume-window-into-column = [ ];
                        "Mod+Period".action.expel-window-from-column = [ ];
                        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
                        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
                        "Mod+R".action.switch-preset-column-width = [ ];
                        "Mod+Shift+R".action.reset-window-height = [ ];
                        "Mod+F".action.maximize-column = [ ];
                        "Mod+Shift+F".action.fullscreen-window = [ ];
                        "Mod+Minus".action.set-column-width = [ "-10%" ];
                        "Mod+Equal".action.set-column-width = [ "+10%" ];
                        "Mod+Shift+Minus".action.set-window-height = [ "-10%" ];
                        "Mod+Shift+Equal".action.set-window-height = [ "+10%" ];
                        "Mod+Shift+S".action.screenshot = [ ];
                        "Mod+Ctrl+S".action.screenshot-window = [ ];
                        "Mod+Shift+E".action.quit = [ ];
                        "Mod+Z".action.toggle-overview = [ ];
                      };
                    in
                    mkMerge [
                      windowBindings
                      indexedWorkspaceBindings
                      specialBindings
                    ];
                  cursor = {
                    # TODO: light / dark
                    theme = config.theme.dark.cursorTheme;
                    size = config.theme.dark.cursorSize;
                  };
                };
              };

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
