# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/etc/etc.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    attrValues
    recursiveUpdate
    mapAttrsToList
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.lists) filter all;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkDefault mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings)
    concatStringsSep
    concatMapStringsSep
    escapeShellArgs
    hasPrefix
    ;
in
{
  flake.nixosModules.netns =
    {
      options,
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.passthru.netns.lib) mkNetnsOption mkRuntimeDirectoryPath;
      inherit (config.environment) etc;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, config, ... }:
        {
          _file = ./confext.nix;

          options = {
            confExcludePaths = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                List of {file}`/etc` paths to be excluded before merging
                with {option}`confext` in the auxiliary namespace.
              '';
            };
            confext = mkOption {
              inherit (options.environment.etc) type;
              default = { };
              description = ''
                Per-network namespace additional entries that will be
                merged into {file}`/etc` in the auxiliary mount namespace.
              '';
            };
          };

          config = mkIf config.enable (
            let
              filteredEtc = filterAttrs (
                _: v: all (p: v.target != p && !hasPrefix "${p}/" v.target) config.confExcludePaths
              ) etc;
              etc' = filter (f: f.enable) (attrValues (recursiveUpdate filteredEtc config.confext));
              etcHardlinks = filter (f: f.mode != "symlink" && f.mode != "direct-symlink") etc';
            in
            {
              build.etcMetadataImage =
                let
                  etcJson = pkgs.writeText "etc-json" (builtins.toJSON etc');
                  etcDump = pkgs.runCommand "etc-dump" { } ''
                    ${getExe pkgs.buildPackages.python3} ${
                      pkgs.path + /nixos/modules/system/etc/build-composefs-dump.py
                    } ${etcJson} > $out
                  '';
                in
                pkgs.runCommand "etc-metadata.erofs"
                  {
                    nativeBuildInputs = with pkgs.buildPackages; [
                      composefs
                      erofs-utils
                    ];
                  }
                  ''
                    mkcomposefs --from-file ${etcDump} $out
                    fsck.erofs $out
                  '';

              build.etcBasedir = pkgs.runCommandLocal "etc-lowerdir" { } ''
                set -euo pipefail

                makeEtcEntry() {
                  src="$1"
                  target="$2"

                  mkdir -p "$out/$(dirname "$target")"
                  cp "$src" "$out/$target"
                }

                mkdir -p "$out"
                ${concatMapStringsSep "\n" (
                  etcEntry:
                  escapeShellArgs [
                    "makeEtcEntry"
                    # force local source paths to be added to the store
                    "${etcEntry.source}"
                    etcEntry.target
                  ]
                ) etcHardlinks}
              '';

              unitConfig = {
                After = [ "netns-${name}-confext.service" ];
              };

              # paths that should not inherit from `config.environment.etc`
              confExcludePaths = [
                # keep-sorted start
                "bird"
                "gai.conf"
                "hosts"
                "iproute2"
                "nscd.conf"
                "nsswitch.conf"
                "resolv.conf"
                "resolvconf.conf"
                "sysctl.d"
                "systemd/network"
                "systemd/networkd.conf"
                "systemd/resolved.conf"
                "tmpfiles.d"
                # keep-sorted end
              ];

              confext."resolv.conf" = mkDefault {
                text = ''
                  nameserver 2001:4860:4860::8888
                  nameserver 2606:4700:4700::1111
                  nameserver 1.1.1.1
                  nameserver 8.8.8.8
                '';
              };
            }
          );
        }
      );

      config = {
        assertions = [
          {
            assertion = config.system.etc.overlay.enable && (!config.system.etc.overlay.mutable);
            message = ''
              Immutable `/etc` without bind-mounts is required since per-netns
              `/etc` is constructed based on `config.environment.etc`.
            '';
          }
        ];

        system.extraSystemBuilderCmds = ''
          ${concatStringsSep "\n" (
            mapAttrsToList (name: cfg: ''
              mkdir -p $out/netns/${name}
              ln -s ${cfg.build.etcMetadataImage} $out/netns/${name}/etc-metadata-image
              ln -s ${cfg.build.etcBasedir}       $out/netns/${name}/etc-basedir
            '') enabledNetns
          )}
        '';

        systemd.services = mapAttrs' (
          name: cfg:
          let
            confextPath = mkRuntimeDirectoryPath name "confext";
            etcPath = "${cfg.rootDirectory}/etc";
          in
          nameValuePair "netns-${name}-confext" {
            path = with pkgs; [
              coreutils
              util-linux
              move-mount-beneath
            ];
            script = ''
              etcMetadataImage=$(readlink -f /run/current-system/netns/${name}/etc-metadata-image)
              etcBasedir=$(readlink -f /run/current-system/netns/${name}/etc-basedir)

              mkdir -p ${etcPath}
              mkdir -p ${confextPath}
              tmpMetadataMount=$(TMPDIR="${confextPath}" mktemp --directory -t nixos-etc-metadata.XXXXXXXXXX)
              mount --type erofs -o ro "$etcMetadataImage" "$tmpMetadataMount"

              if ! mountpoint -q ${etcPath}; then
                mount --type overlay overlay \
                  --options "lowerdir=$tmpMetadataMount::$etcBasedir,relatime,redirect_dir=on,metacopy=on" \
                  ${etcPath}
              else
                tmpEtcMount=$(TMPDIR="${confextPath}" mktemp --directory -t nixos-etc.XXXXXXXXXX)
                mount --bind --make-private "$tmpEtcMount" "$tmpEtcMount"
                mount --type overlay overlay \
                  --options "lowerdir=$tmpMetadataMount::$etcBasedir,relatime,redirect_dir=on,metacopy=on" \
                  "$tmpEtcMount"
                move-mount --move --beneath "$tmpEtcMount" ${etcPath}
                umount --lazy --recursive ${etcPath}
                umount --lazy "$tmpEtcMount"
                rmdir "$tmpEtcMount"
              fi

              findmnt --type erofs --list --kernel --output TARGET | while read -r mountPoint; do
                if [[ "$mountPoint" =~ ^${confextPath}/nixos-etc-metadata\..{10}$ && "$mountPoint" != "$tmpMetadataMount" ]]; then
                  umount --lazy "$mountPoint"
                  rmdir "$mountPoint"
                fi
              done
            '';
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            after = [ "netns-${name}.service" ];
            partOf = [ "netns-${name}.service" ];
            wants = [ "netns-${name}.service" ];
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
          }
        ) enabledNetns;

        # hack
        system.activationScripts.netns-confext = {
          deps = [ "etc" ];
          text = ''
            ${concatStringsSep "\n" (
              mapAttrsToList (name: _cfg: ''
                if [[ ! $IN_NIXOS_SYSTEMD_STAGE1 ]] && ${config.systemd.package}/bin/systemctl is-active --quiet "netns-${name}-confext.service"; then
                  echo "netns-${name}-confext.service" >> /run/nixos/activation-restart-list
                fi
              '') enabledNetns
            )}
          '';
        };
      };
    };
}
