{
  flake.unify.modules."nix/common" = {
    nixos = {
      meta = {
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
        requires = [ "imports/preservation" ];
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

          preservation.preserveAt.cache.directories = [ ".cache/nix" ];

          preservation.preserveAt.state.directories = [ ".local/share/nix" ];
        };
    };
  };
}
