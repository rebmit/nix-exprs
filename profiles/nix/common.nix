{
  unify.modules."nix/common" = {
    nixos = {
      meta = {
        tags = [ "nix" ];
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
