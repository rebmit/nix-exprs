{
  unify.features.system._.misc._.fontconfig =
    { ... }:
    {
      nixos =
        { ... }:
        {
          fonts = {
            enableDefaultPackages = false;
            fontconfig.enable = true;
          };
        };

      darwin =
        { pkgs, ... }:
        let
          pkg = pkgs.fontconfig;

          confPkg =
            pkgs.runCommand "fontconfig-conf"
              {
                preferLocalBuild = true;
              }
              ''
                dst=$out/etc/fonts/conf.d
                mkdir -p $dst

                ln -s ${pkg.out}/etc/fonts/fonts.conf $dst/../fonts.conf
                ln -s ${pkg.out}/etc/fonts/conf.d/*.conf $dst/
              '';

          fontconfigEtc = pkgs.buildEnv {
            name = "fontconfig-etc";
            paths = [ confPkg ];
            ignoreCollisions = true;
          };
        in
        {
          environment = {
            systemPackages = [ pkgs.fontconfig ];
            etc.fonts.source = "${fontconfigEtc}/etc/fonts";
          };
        };
    };
}
