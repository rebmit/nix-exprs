{
  unify.profiles.system._.nixos._.kernel._.latest =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
}
