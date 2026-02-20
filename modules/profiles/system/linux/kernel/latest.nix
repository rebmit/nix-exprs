{
  unify.profiles.system._.linux._.kernel._.latest =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
}
