let
  systemsModule = _: {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
in
{
  imports = [ systemsModule ];

  flake.modules.flake.systems = systemsModule;
}
