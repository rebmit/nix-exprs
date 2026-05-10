{ __findFile, ... }:

{
  includes = [ <rebmit/features/system/config/nix> ];

  configs.host =
    { ... }:
    {
      nix = {
        settings = {
          # keep-sorted start block=yes
          experimental-features = [ "flakes" ];
          flake-registry = "";
          use-registries = true;
          # keep-sorted end
        };
      };
    };
}
