{ lib, ... }:
let
  inherit (lib.meta) getExe';
in
{
  scopes.default =
    { final, prev, ... }:
    {
      qemu = prev.qemu.overrideAttrs {
        version = "10.2.0-unstable-2026-01-06";
        src = final.fetchFromGitHub {
          owner = "rebmit";
          repo = "qemu";
          rev = "3ed318f65253c24c380ff805a8c326bcace0b251";
          fetchSubmodules = true;
          hash = "sha256-s3nHA1Wl8nDduaiJimKBTMaxSUY7UTUxj5Y2ufSiLRI=";
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
      inherit (pkgs) qemu qemu_kvm qemu-user;
    };
}
