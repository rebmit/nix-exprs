{
  unify.profiles.system._.os-specific._.linux._.kernel._.testing =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_testing;
        };
    };
}
