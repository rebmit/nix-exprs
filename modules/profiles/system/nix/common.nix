{ lib, __findFile, ... }:

{
  includes = [ <rebmit/features/system/config/nix> ];

  configs.host =
    { pkgs, ... }:
    {
      nix = {
        settings = {
          # keep-sorted start block=yes
          builders-use-substitutes = true;
          experimental-features = [
            # keep-sorted start
            "fetch-tree"
            "nix-command"
            # keep-sorted end
          ];
          keep-derivations = true;
          keep-going = true;
          keep-outputs = true;
          use-xdg-base-directories = true;
          # keep-sorted end
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          # keep-sorted start block=yes
          allowed-users = [ "@staff" ];
          trusted-users = [ "@admin" ];
          # keep-sorted end
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          # keep-sorted start block=yes
          allowed-users = [ "@users" ];
          auto-allocate-uids = true;
          auto-optimise-store = true;
          experimental-features = [
            # keep-sorted start
            "auto-allocate-uids"
            "cgroups"
            "fetch-tree"
            "nix-command"
            # keep-sorted end
          ];
          trusted-users = [ "@wheel" ];
          use-cgroups = true;
          # keep-sorted end
        };
      };
    };
}
