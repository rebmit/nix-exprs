{ lib, ... }:

{
  host ? null,
  ...
}:

{
  includes = [ ./. ];

  configs.user =
    { ... }:
    {
      nix = lib.mkIf (host == null) {
        settings = {
          builders-use-substitutes = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          flake-registry = "";
          keep-derivations = true;
          keep-going = true;
          keep-outputs = true;
          use-xdg-base-directories = true;
        };
      };
    };
}
