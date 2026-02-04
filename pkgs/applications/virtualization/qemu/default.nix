{ lib, ... }:
let
  inherit (builtins) filter;
  inherit (lib.meta) getExe';
  inherit (lib.strings) hasInfix;
in
{
  overlays.default =
    { final, prev, ... }:
    {
      qemu = prev.qemu.overrideAttrs (oldAttrs: {
        version = "10.2.0-unstable-2026-02-04";
        src = final.fetchFromGitHub {
          owner = "rebmit";
          repo = "qemu";
          rev = "5af00a36710bb23871d733383903fd7329e6769b";
          fetchSubmodules = true;
          hash = "sha256-rZXPwXfML4R6fdQAdIc9QAzRn8tdujlB9v43CQR8IiM=";
          postFetch = ''
            cd $out
            subprojects="keycodemapdb libvfio-user berkeley-softfloat-3 berkeley-testfloat-3"
            for sp in $subprojects; do
              ${getExe' prev.meson "meson"} subprojects download $sp
            done
            rm -r subprojects/*/.git
          '';
        };
        patches = filter (p: !hasInfix "termios" p) (oldAttrs.patches or [ ]);
      });
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) qemu_kvm;
      };
    };
}
