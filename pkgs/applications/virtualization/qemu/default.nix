{ lib, ... }:
let
  inherit (lib.meta) getExe';
in
{
  scopes.default =
    { final, prev, ... }:
    {
      qemu = prev.qemu.overrideAttrs {
        version = "10.1.2-unstable-2025-12-13";
        src = final.fetchFromGitHub {
          owner = "rebmit";
          repo = "qemu";
          rev = "747bb69f67c4aa30e89f6523fe932960c62a31c5";
          fetchSubmodules = true;
          hash = "sha256-wrd+3GXpZ8VxuVjkPHZubTJRhexKRvors3uZ1L7cNVk=";
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
}
