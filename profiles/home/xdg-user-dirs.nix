{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."home/xdg-user-dirs" = {
    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
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
            extraConfig = {
              XDG_PROJECTS_DIR = mkDefault "$HOME/Projects";
            };
          };

          preservation.directories = [
            "Documents"
            "Downloads"
            "Music"
            "Pictures"
            "Videos"
            "Projects"
          ];
        };
    };
  };
}
