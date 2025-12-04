{
  flake.unify.modules."misc/documentation" = {
    nixos = {
      module =
        { pkgs, ... }:
        {
          documentation = {
            enable = true;
            doc.enable = false;
            info.enable = false;
            man = {
              enable = true;
              generateCaches = false;
              man-db.enable = true;
            };
            nixos.enable = true;
          };

          environment.systemPackages = with pkgs; [
            # keep-sorted start
            man-pages
            man-pages-posix
            # keep-sorted end
          ];
        };
    };

    homeManager = {
      module =
        { ... }:
        {
          programs.man.generateCaches = false;
        };
    };
  };
}
