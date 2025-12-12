{ lib, ... }:
let
  inherit (lib.lists) elem;
  inherit (lib.strings) getName;
in
{
  perSystem = {
    nixpkgs.predicates = {
      allowNonSource =
        p:
        elem (getName p) [
          # keep-sorted start
          "libreoffice"
          "zotero"
          # keep-sorted end
        ];
    };
  };

  flake.unify.modules."programs/collections/desktop" = {
    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # keep-sorted start block=yes
            (mpv.override {
              scripts = with pkgs.mpvScripts; [
                # keep-sorted start
                modernz
                mpris
                thumbfast
                # keep-sorted end
              ];
            })
            bustle
            dmlive
            door-knocker
            evolution
            foliate
            ghostty
            gimp3
            libreoffice-fresh
            loupe
            nautilus
            nheko
            papers
            seahorse
            swappy
            telegram-desktop
            zotero
            # keep-sorted end
          ];

          preservation.preserveAt.state.directories = [
            ".zotero"

            ".cache/evolution"
            ".cache/org.gnome.Evolution"
            ".config/dconf"
            ".config/evolution"
            ".config/nheko"
            ".local/share/evolution"
            ".local/share/org.gnome.Evolution"
            ".local/share/nheko"
            ".local/share/TelegramDesktop"

            ".pki/nssdb"

            "Zotero"
          ];
        };
    };
  };
}
