{
  unify.modules."system/documentation" = {
    nixos = {
      meta = {
        tags = [ "base" ];
      };

      module = _: {
        documentation = {
          enable = true;
          doc.enable = false;
          info.enable = false;
          man = {
            enable = true;
            generateCaches = false;
            man-db.enable = true;
          };
          nixos.enable = false;
        };
      };
    };
  };
}
