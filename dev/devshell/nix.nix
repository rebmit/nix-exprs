{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        commands = map (cmd: cmd // { category = "nix"; }) [
          {
            package = pkgs.nix-update;
            help = "Swiss-knife for updating nix packages";
          }
          {
            package = pkgs.nixd;
            help = "Feature-rich Nix language server interoperating with C++ nix";
          }
          {
            package = pkgs.nixos-anywhere;
            help = "Install nixos everywhere via ssh";
          }
        ];
      };
    };
}
