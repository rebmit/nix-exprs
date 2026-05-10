{ __findFile, ... }:

{
  includes = [ <rebmit/features/user/config/nix> ];

  configs.user =
    { ... }:
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
        };
      };
    };
}
