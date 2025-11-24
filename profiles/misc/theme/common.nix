{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.strings) substring;
  inherit (lib.trivial) readFile;

  themeOptions = {
    options = {
      # keep-sorted start block=yes
      base24Theme = mkOption {
        type = types.attrs;
        description = ''
          Base24 theme definition to use.
        '';
      };
      cursorSize = mkOption {
        type = types.int;
        description = ''
          Size of the cursor.
        '';
      };
      cursorTheme = mkOption {
        type = types.str;
        description = ''
          Name of the cursor theme to use.
        '';
      };
      ghosttyTheme = mkOption {
        type = types.str;
        description = ''
          Name of the Ghostty theme to use.
        '';
      };
      gtkTheme = mkOption {
        type = types.str;
        description = ''
          Name of the GTK theme to use.
        '';
      };
      helixTheme = mkOption {
        type = types.str;
        description = ''
          Path to the Helix theme to use.
        '';
      };
      iconTheme = mkOption {
        type = types.str;
        description = ''
          Name of the icon theme to use.
        '';
      };
      wallpaper = mkOption {
        type = types.str;
        description = ''
          Path to the wallpaper to use.
        '';
      };
      # keep-sorted end
    };
  };

  importBase24Theme =
    file:
    let
      inherit (fromTOML (readFile file)) palette;
    in
    mapAttrs (_: value: substring 1 6 value) palette;
in
{
  flake.unify.modules."misc/theme/common" = {
    homeManager = {
      module =
        { ... }:
        {
          options.theme = {
            light = mkOption {
              type = types.submodule themeOptions;
              default = { };
              description = ''
                The light theme configuration.
              '';
            };
            dark = mkOption {
              type = types.submodule themeOptions;
              default = { };
              description = ''
                The dark theme configuration.
              '';
            };
          };

          config = {
            lib.theme = {
              inherit importBase24Theme;
            };
          };
        };
    };
  };
}
