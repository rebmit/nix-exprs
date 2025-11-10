{
  unify.modules."nix/gc" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "nix/common" ];
      };

      module = _: {
        nix = {
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
          };

          settings.min-free = 1024 * 1024 * 1024; # bytes
        };
      };
    };
  };
}
