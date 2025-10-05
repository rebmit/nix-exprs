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
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings)
    concatStringsSep
    concatMapStringsSep
    escapeShellArgs
    hasPrefix
    ;

  bindMountOptions =
    { name, ... }:
    {
      options = {
        enable = mkEnableOption "the bind mount" // {
          default = true;
        };
        mountPoint = mkOption {
          type = types.str;
          description = ''
            The mount point in the auxiliary mount namespace.
          '';
        };
        hostPath = mkOption {
          type = types.str;
          description = ''
            The host path in the init mount namespace.
          '';
        };
        isReadOnly = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Whether the mounted path should be accessed in read-only mode.
          '';
        };
      };

      config = {
        mountPoint = mkDefault name;
        hostPath = mkDefault name;
      };
    };
in
{
  flake.modules.nixos.netns =
    {
      options,
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.passthru.netns) mkNetnsOption mkRuntimeDirectoryPath;
      inherit (config.environment) etc;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, config, ... }:
        {
          _file = ./rootfs.nix;

          options = {
            rootDirectory = mkOption {
              type = types.str;
              default = mkRuntimeDirectoryPath name "rootfs";
              readOnly = true;
              description = ''
                Root directory in the auxiliary mount namespace for the
                network namespace, relative to the host's root directory.

                This implementation may have issues with propagation of
                top-level mount points, but will be used consistently
                until systemd supports `AT_SYMLINK_NOFOLLOW`, at which
                point we can possibly drop the use of chroot/pivot_root.

                See https://github.com/systemd/systemd/issues/32366.
              '';
            };
            bindMounts = mkOption {
              type = types.attrsOf (types.submodule bindMountOptions);
              default = { };
              description = ''
                Per-network namespace bind mounts into the new root of the
                auxiliary mount namespace.
              '';
            };
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

              config =
                let
                  enabledBindMounts = filter (d: d.enable) (attrValues config.bindMounts);
                  rwBinds = filter (d: !d.isReadOnly) enabledBindMounts;
                  roBinds = filter (d: d.isReadOnly) enabledBindMounts;
                in
                {
                  serviceConfig = {
                    RootDirectory = config.rootDirectory;
                    MountAPIVFS = "yes";
                    TemporaryFileSystem = [ "/run/netns-${name}" ]; # workaround
                    BindPaths = map (d: "${d.hostPath}:${d.mountPoint}:rbind") rwBinds;
                    BindReadOnlyPaths = map (d: "${d.hostPath}:${d.mountPoint}:rbind") roBinds;
                  };
                  after = [ "netns-${name}-confext.service" ];
                };

              # per systemd-tmpfiles rules and activation scripts
              bindMounts = {
                "/bin" = { };
                "/home" = { };
                "/nix" = { };
                "/root" = { };
                "/run" = { };
                "/srv" = { };
                "/tmp" = { };
                "/usr" = { };
                "/var" = { };
              };

              # paths that should not inherit from `config.environment.etc`
              confExcludePaths = [
                # keep-sorted start
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
        system.activationScripts.confext = {
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
