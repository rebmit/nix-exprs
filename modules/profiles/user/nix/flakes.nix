{ __findFile, ... }:

{
  includes = [ <rebmit/features/user/config/nix> ];

  configs.user =
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
