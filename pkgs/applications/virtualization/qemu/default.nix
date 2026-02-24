{ lib, ... }:
let
  inherit (lib.meta) getExe';
in
{
  scopes.default =
    { final, prev, ... }:
    {
      qemu = prev.qemu.overrideAttrs {
        version = "10.2.0-unstable-2026-02-24";
        src = final.fetchFromGitHub {
          owner = "rebmit";
          repo = "qemu";
          rev = "5bdc4c5a18a42cae19af8047e0e4bdd970636d6e";
          fetchSubmodules = true;
          hash = "sha256-siBefUzo/IVqd66ycDIVKjft6bq7U3laiRcEirJhKDA=";
          postFetch = ''
            cd $out
            subprojects="keycodemapdb libvfio-user berkeley-softfloat-3 berkeley-testfloat-3"
            for sp in $subprojects; do
              ${getExe' prev.meson "meson"} subprojects download $sp
            done
            rm -r subprojects/*/.git
          '';
        };
      };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) qemu_kvm;
    };
}
