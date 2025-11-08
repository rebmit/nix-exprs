{
  unify.modules."nix/common" = {
    nixos = {
      meta = {
        tags = [ "nix" ];
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
