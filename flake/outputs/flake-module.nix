{ self, ... }:
let
  inherit (self.lib.path) buildModuleList;
in
{
  flake.flakeModule = {
    imports = buildModuleList ../modules;
  };
}
