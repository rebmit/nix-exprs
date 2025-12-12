# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/d40b75ca0955d2a999b36fa1bd0f8b3a6e061ef3/home-manager/profiles/niri/default.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.lists) optionals;
in
{
  flake.unify.modules."services/user/cliphist" = {
    homeManager = {
      module =
        { config, pkgs, ... }:
        {
          home.packages = [
            pkgs.cliphist
          ]
          ++ optionals config.programs.fuzzel.enable [
            (pkgs.writeShellApplication {
              name = "cliphist-fuzzel";
              runtimeInputs = with pkgs; [
                wl-clipboard
                config.programs.fuzzel.package
                config.services.cliphist.package
              ];
              text = ''
                cliphist list | fuzzel -d | cliphist decode | wl-copy
              '';
            })
          ];

          systemd.user.services.cliphist = {
            Unit = {
              Description = "Clipboard management daemon";
              ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
              Requisite = [ "graphical-session.target" ];
            };
            Install.WantedBy = [ "graphical-session.target" ];
            Service = {
              Type = "simple";
              Restart = "on-failure";
              ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
            };
          };

          systemd.user.services.cliphist-images = {
            Unit = {
              Description = "Clipboard management daemon - images";
              ConditionEnvironment = lib.singleton "WAYLAND_DISPLAY";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
              Requisite = [ "graphical-session.target" ];
            };
            Install.WantedBy = [ "graphical-session.target" ];
            Service = {
              Type = "simple";
              Restart = "on-failure";
              ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
            };
          };
        };
    };
  };
}
