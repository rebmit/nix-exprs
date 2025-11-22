{
  flake.unify.modules."nix/registry" = {
    nixos = {
      meta = {
        requires = [
          "nix/common"
          "nix/settings"
        ];
      };

      module =
        { self, ... }:
        {
          nixpkgs.flake = {
            setFlakeRegistry = true;
            setNixPath = true;
          };

          nix = {
            registry.p.flake = self;
            settings = {
              flake-registry = "/etc/nix/registry.json";
            };
          };
        };
    };
  };
}
