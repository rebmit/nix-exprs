{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) filterAttrs attrValues mapAttrsToList;
  inherit (lib.lists) filter;
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) concatStringsSep;

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
          default = true;
          description = ''
            Whether the mounted path should be accessed in read-only mode.
          '';
        };
        recursive = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether to perform a recursive bind mount.
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
    { config, ... }:
    let
      inherit (config.passthru.netns.lib) mkNetnsOption mkRuntimeDirectoryPath;

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
          };

          config = mkIf config.enable {
            # minimal required bind mounts per systemd-tmpfiles rules and activation scripts
            bindMounts = {
              "/nix" = { };
              "/var" = { };
              "/bin" = { };
              "/usr" = { };

              "/run" = {
                hostPath = "${config.rootDirectory}/run";
                isReadOnly = false;
              };
            };

            serviceConfig =
              let
                toRecursiveOption = flag: if flag then "rbind" else "norbind";

                enabledBindMounts = filter (d: d.enable) (attrValues config.bindMounts);
                rwBinds = filter (d: !d.isReadOnly) enabledBindMounts;
                roBinds = filter (d: d.isReadOnly) enabledBindMounts;
              in
              {
                ProtectSystem = "strict";
                RootDirectory = config.rootDirectory;
                MountAPIVFS = "yes";
                BindPaths = map (d: "${d.hostPath}:${d.mountPoint}:${toRecursiveOption d.recursive}") rwBinds;
                BindReadOnlyPaths = map (
                  d: "${d.hostPath}:${d.mountPoint}:${toRecursiveOption d.recursive}"
                ) roBinds;
              };
          };
        }
      );

      config = {
        system.activationScripts.netns-rootfs = {
          deps = [ "etc" ];
          text = ''
            ${concatStringsSep "\n" (
              mapAttrsToList (_: cfg: ''
                mkdir -p "${cfg.rootDirectory}/run"
                ln -sfn "$(readlink -f "$systemConfig")" "${cfg.rootDirectory}/run/current-system"
              '') enabledNetns
            )}
          '';
        };
      };
    };
}
