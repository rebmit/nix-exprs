{ lib, ... }:
let
  inherit (lib.lists) optionals elem;
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."home/preservation" = {
    homeManager = {
      meta = {
        tags = [
          "baseline"
          "development"
        ];
        requires = [ "external/preservation" ];
      };

      module =
        { unify, ... }:
        {
          xdg.userDirs = {
            enable = true;
            createDirectories = true;
            desktop = mkDefault "/var/empty";
            documents = mkDefault "$HOME/Documents";
            download = mkDefault "$HOME/Downloads";
            music = mkDefault "$HOME/Music";
            pictures = mkDefault "$HOME/Pictures";
            publicShare = mkDefault "/var/empty";
            templates = mkDefault "/var/empty";
            videos = mkDefault "$HOME/Videos";
          };

          preservation.directories =
            optionals (elem "baseline" unify.meta.tags) [
              "Documents"
              "Downloads"
              "Music"
              "Pictures"
              "Videos"
            ]
            ++ optionals (elem "development" unify.meta.tags) [
              "Projects"
            ];
        };
    };
  };
}
