{ lib, ... }:
let
  inherit (builtins) attrValues mapAttrs;
  inherit (lib.meta) setPrio defaultPriority;
in
{
  unify.features.system._.misc._.tools =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          environment = {
            defaultPackages = [ ];
            systemPackages = attrValues {
              inherit (pkgs)
                # keep-sorted start
                _7zz
                binutils
                dnsutils
                fd
                jq
                openssl
                psmisc
                ripgrep
                strace
                unar
                unzipNLS
                zip
                # keep-sorted end
                ;
            };
          };

          programs.htop = {
            enable = true;
            settings = {
              show_program_path = 0;
              highlight_base_name = 1;
              hide_userland_threads = true;
            };
          };
        };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = attrValues (
            {
              inherit (pkgs)
                # keep-sorted start
                _7zz
                binutils
                dnsutils
                fd
                htop
                jq
                openssl
                ripgrep
                unar
                unzipNLS
                zip
                # keep-sorted end
                ;
            }
            // mapAttrs (_: pkg: setPrio (pkg.meta.priority or defaultPriority + 3) pkg) {
              inherit (pkgs)
                # keep-sorted start
                bashInteractive
                bzip2
                coreutils-full
                cpio
                curl
                diffutils
                findutils
                gawk
                getconf
                getent
                gnugrep
                gnupatch
                gnused
                gnutar
                gzip
                less
                ncurses
                netcat
                time
                util-linux
                which
                xz
                zstd
                # keep-sorted end
                ;
            }
          );
        };
    };
}
