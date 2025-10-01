{
  inputs,
  self,
  ...
}:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        localSystem = { inherit system; };
        overlays = [ self.overlays.default ];
      };
    };
}
