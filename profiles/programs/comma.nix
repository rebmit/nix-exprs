{
  flake.unify.modules."programs/comma" = {
    homeManager = {
      meta = {
        requires = [ "imports/self/preservation" ];
      };

      module =
        { inputs, pkgs, ... }:
        {
          home.packages = [
            inputs.nix-index-database.packages.${pkgs.stdenv.hostPlatform.system}.comma-with-db
          ];

          preservation.preserveAt.state.directories = [ ".local/state/comma" ];
        };
    };
  };
}
