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

    homeManager = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "external/preservation" ];
      };

      module =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # keep-sorted start
            dix
            nix-melt
            nix-tree
            nix-update
            nixd
            nixpkgs-review
            # keep-sorted end
          ];

          preservation.directories = [
            ".cache/nix"
            ".local/share/nix"
          ];
        };
    };
  };
}
