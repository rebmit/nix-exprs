{
  perSystem =
    { pkgs, ... }:
    let
      canokey-udev-rules =
        {
          lib,
          stdenvNoCC,
        }:

        stdenvNoCC.mkDerivation {
          pname = "canokey-udev-rules";
          version = "0-unstable-2025-10-01";

          src = ./69-canokey.rules;
          dontUnpack = true;

          installPhase = ''
            install -D -m444 $src $out/lib/udev/rules.d/69-canokey.rules
          '';

          meta = {
            description = "udev rules for CanoKey";
            homepage = "https://docs.canokeys.org/userguide/setup";
            maintainers = with lib.maintainers; [ rebmit ];
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      packages.canokey-udev-rules = pkgs.callPackage canokey-udev-rules { };
    };
}
