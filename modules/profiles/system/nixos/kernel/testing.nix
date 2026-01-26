{
  unify.profiles.system._.nixos._.kernel._.testing =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_testing;
        };
    };
}
