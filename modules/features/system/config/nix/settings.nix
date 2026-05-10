{ lib, __findFile, ... }:

{ host, ... }:

{
  includes = [
    ./.

    <rebmit/features/system/misc/class>
  ];

  configs.host =
    { ... }:
    {
      nix = {
        settings = {
          builders-use-substitutes = true;
          flake-registry = "";
          keep-derivations = true;
          keep-going = true;
          keep-outputs = true;
          use-xdg-base-directories = true;
        }
        // lib.optionalAttrs (host.config.system.class == "darwin") {
          allowed-users = [ "@staff" ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          trusted-users = [ "@admin" ];
        }
        // lib.optionalAttrs (host.config.system.class == "nixos") {
          allowed-users = [ "@users" ];
          auto-allocate-uids = true;
          auto-optimise-store = true;
          experimental-features = [
            "nix-command"
            "flakes"
            "auto-allocate-uids"
            "cgroups"
          ];
          trusted-users = [ "@wheel" ];
          use-cgroups = true;
        };
      };
    };
}
