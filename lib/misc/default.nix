{ lib, self, ... }:
let
  serviceHardened = import ./service-hardened.nix { inherit lib self; };
in
{
  inherit serviceHardened;
}
