{
  unify.modules."nix/registry" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
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
            setNixPath = false;
          };

          nix = {
            registry.p.flake = self;
            settings = {
              flake-registry = "/etc/nix/registry.json";
              nix-path = [
                "nixpkgs=flake:nixpkgs"
                "p=flake:p"
              ];
            };
          };
        };
    };
  };
}
