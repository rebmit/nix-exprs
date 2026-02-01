{
  unify.profiles.nix =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          nix = {
            package = pkgs.nixVersions.latest;
            channel.enable = false;
            settings = {
              # keep-sorted start block=yes
              allowed-users = [ "@users" ];
              auto-allocate-uids = true;
              auto-optimise-store = true;
              builders-use-substitutes = true;
              experimental-features = [
                "nix-command"
                "flakes"
                "auto-allocate-uids"
                "cgroups"
              ];
              flake-registry = "";
              keep-derivations = true;
              keep-outputs = true;
              trusted-users = [ "@wheel" ];
              use-cgroups = true;
              use-xdg-base-directories = true;
              # keep-sorted end
            };
          };
        };
    };
}
