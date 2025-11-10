{
  flake.unify.modules."nix/common" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "programs/git" ];
      };

      module =
        { pkgs, ... }:
        {
          nix = {
            enable = true;
            package = pkgs.nixVersions.latest;
          };
        };
    };
  };
}
