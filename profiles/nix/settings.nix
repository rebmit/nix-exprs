{
  unify.modules."nix/settings" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "nix/common" ];
      };

      module = _: {
        nix = {
          channel.enable = false;
          settings = {
            experimental-features = [
              "nix-command"
              "flakes"
              "auto-allocate-uids"
              "cgroups"
            ];
            use-xdg-base-directories = true;
            keep-outputs = true;
            keep-derivations = true;
            builders-use-substitutes = true;
            auto-allocate-uids = true;
            use-cgroups = true;
            auto-optimise-store = true;
          };
        };

        systemd.services.nix-daemon.serviceConfig.Environment = [ "TMPDIR=/var/tmp" ];
      };
    };
  };
}
