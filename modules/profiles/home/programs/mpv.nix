{ lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.lists) optionals;
in
{
  unify.profiles.home._.programs._.mpv =
    { ... }:
    {
      requires = [ "profiles/system/misc/fontconfig" ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [
            (pkgs.mpv.override {
              # https://github.com/NixOS/nixpkgs/issues/464174
              extraMakeWrapperArgs = optionals pkgs.stdenv.hostPlatform.isDarwin [
                "--append-flag"
                "--osd-font-provider=fontconfig"
              ];
              scripts = attrValues (
                {
                  inherit (pkgs.mpvScripts)
                    # keep-sorted start
                    modernz
                    thumbfast
                    # keep-sorted end
                    ;
                }
                // optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
                  inherit (pkgs.mpvScripts) mpris;
                }
              );
            })
          ];
        };
    };
}
