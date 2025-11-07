# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/lib.nix (MIT License)
# https://github.com/linyinfeng/dotfiles/blob/7b5cb693088c2996418d44a3f1203680762ed97d/nixos/modules/environment/global-persistence/default.nix (MIT License)
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/systemd/tmpfiles.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists)
    concatLists
    filter
    optional
    optionals
    remove
    unique
    sort
    singleton
    ;
  inherit (lib.modules)
    evalModules
    mkDefault
    mkMerge
    ;
  inherit (lib.options) mkOption;
  inherit (lib.strings)
    escapeC
    concatStringsSep
    concatStrings
    hasPrefix
    optionalString
    ;
  inherit (lib.trivial) lessThan;
  inherit (self.lib.path)
    concatPath
    concatPaths
    parentDirectory
    ;

  escapeArgument = escapeC [
    "\t"
    "\n"
    "\r"
    " "
    "\\"
  ];

  settingsEntryToRule = path: entry: ''
    '${entry.type}' '${path}' '${entry.mode}' '${entry.user}' '${entry.group}' '${entry.age}' ${escapeArgument entry.argument}
  '';

  pathsToRules = mapAttrsToList (
    path: types: concatStrings (mapAttrsToList (_type: settingsEntryToRule path) types)
  );

  toOptionsString =
    mountOptions:
    concatStringsSep "," (
      map (
        option: if option.value == null then option.name else "${option.name}=${option.value}"
      ) mountOptions
    );

  parentNormalize = prefix: paths: sort lessThan (filter (hasPrefix prefix) (unique paths));
  parentDirectories = prefix: paths: parentNormalize prefix (map parentDirectory paths);

  parentClosure =
    prefix: paths:
    let
      iter = parentNormalize prefix (paths ++ parentDirectories prefix paths);
    in
    if iter == paths then iter else parentClosure prefix iter;

  getAllDirectories =
    stateConfig: stateConfig.directories ++ (concatLists (getUserDirectories stateConfig.users));
  getAllFiles = stateConfig: stateConfig.files ++ (concatLists (getUserFiles stateConfig.users));
  getUserDirectories = mapAttrsToList (_: userConfig: userConfig.directories);
  getUserFiles = mapAttrsToList (_: userConfig: userConfig.files);
  onlyForInitrd = forInitrd: filter (conf: conf.inInitrd == forInitrd);
in
{
  flake.nixosModules.preservation =
    { options, ... }:
    let
      mkRuleFileContent =
        paths:
        let
          evalPaths =
            paths:
            (evalModules {
              modules = [
                {
                  options.settings = mkOption {
                    inherit (options.systemd.tmpfiles.settings) type;
                    default = { };
                  };
                }
                { settings.preservation = mkMerge (paths ++ singleton (mkDefault { })); }
              ];
            }).config.settings.preservation;
        in
        concatStrings (pathsToRules (evalPaths paths));

      mkTmpfilesRules =
        forInitrd: stateConfig:
        let
          allDirectories = onlyForInitrd forInitrd (getAllDirectories stateConfig);
          allFiles = onlyForInitrd forInitrd (getAllFiles stateConfig);

          prefix = if forInitrd then "/sysroot" else "/";

          mountedDirRules = map (
            dirConfig:
            let
              persistentDirPath = concatPaths [
                prefix
                stateConfig.persistentStoragePath
                dirConfig.directory
              ];
            in
            {
              "${persistentDirPath}".d = {
                inherit (dirConfig) user group mode;
              };
            }
          ) allDirectories;

          mountedFileRules = map (
            fileConfig:
            let
              persistentFilePath = concatPaths [
                prefix
                stateConfig.persistentStoragePath
                fileConfig.file
              ];
            in
            {
              "${persistentFilePath}".f = {
                inherit (fileConfig) user group mode;
              };
            }
          ) allFiles;

          rules = mountedDirRules ++ mountedFileRules;
        in
        rules;

      mkMountUnits =
        forInitrd: stateConfig:
        let
          allDirectories = onlyForInitrd forInitrd (getAllDirectories stateConfig);
          allFiles = onlyForInitrd forInitrd (getAllFiles stateConfig);

          prefix = if forInitrd then "/sysroot" else "/";

          directoryMounts = map (directoryConfig: {
            options = toOptionsString (
              directoryConfig.mountOptions
              ++ (optional forInitrd {
                name = "x-initrd.mount";
                value = null;
              })
            );
            where = concatPaths [
              prefix
              directoryConfig.directory
            ];
            what = concatPaths [
              prefix
              stateConfig.persistentStoragePath
              directoryConfig.directory
            ];
            unitConfig.DefaultDependencies = "no";
            conflicts = [ "umount.target" ];
            wantedBy = if forInitrd then [ "initrd-preservation.target" ] else [ "preservation.target" ];
            before =
              if forInitrd then
                [
                  "systemd-tmpfiles-setup-sysroot.service"
                  "initrd-preservation.target"
                ]
              else
                [
                  "systemd-tmpfiles-setup.service"
                  "preservation.target"
                ];
            after =
              if forInitrd then
                [
                  "systemd-tmpfiles-setup-preservation.service"
                ]
              else
                [ "systemd-tmpfiles-setup-preservation.service" ];
          }) allDirectories;

          fileMounts = map (fileConfig: {
            options = toOptionsString (
              fileConfig.mountOptions
              ++ (optional forInitrd {
                name = "x-initrd.mount";
                value = null;
              })
            );
            where = concatPaths [
              prefix
              fileConfig.file
            ];
            what = concatPaths [
              prefix
              stateConfig.persistentStoragePath
              fileConfig.file
            ];
            unitConfig = {
              DefaultDependencies = "no";
              ConditionPathExists = concatPaths [
                prefix
                stateConfig.persistentStoragePath
                fileConfig.file
              ];
            };
            conflicts = [ "umount.target" ];
            wantedBy = if forInitrd then [ "initrd-preservation.target" ] else [ "preservation.target" ];
            before =
              if forInitrd then
                [
                  "systemd-tmpfiles-setup-sysroot.service"
                  "initrd-preservation.target"
                ]
              else
                [
                  "systemd-tmpfiles-setup.service"
                  "preservation.target"
                ];
            after =
              if forInitrd then
                [
                  "systemd-tmpfiles-setup-preservation.service"
                ]
              else
                [ "systemd-tmpfiles-setup-preservation.service" ];
          }) allFiles;

          mountUnits = directoryMounts ++ fileMounts;
        in
        mountUnits;

      mkUserParentClosureTmpfilesRule =
        persistentStoragePath: _: userConfig:
        let
          inherit (userConfig)
            username
            home
            homeGroup
            homeMode
            ;
          directories = map (d: d.directory) userConfig.directories;
          files = map (f: f.file) userConfig.files;
          parents = remove home (parentClosure home (parentDirectories home (directories ++ files)));
          rules =
            map (d: {
              "${d}".d = {
                user = username;
                group = homeGroup;
                mode = homeMode;
              };
              "${concatPath persistentStoragePath d}".d = {
                user = username;
                group = homeGroup;
                mode = homeMode;
              };
            }) parents
            ++ singleton {
              "${concatPath persistentStoragePath home}".d = {
                user = username;
                group = homeGroup;
                mode = homeMode;
              };
            };
        in
        rules;

      mkRegularMountUnits = mkMountUnits false;
      mkInitrdMountUnits = mkMountUnits true;
      mkRegularTmpfilesRules = mkTmpfilesRules false;
      mkInitrdTmpfilesRules = mkTmpfilesRules true;

      mkInitrdTmpfilesService = configPath: persistentStoragePath: {
        wantedBy = [ "initrd-preservation.target" ];
        before = [
          "initrd.target"
          "shutdown.target"
          "initrd-switch-root.target"
          "systemd-tmpfiles-setup-sysroot.service"
          "initrd-preservation.target"
        ];
        conflicts = [
          "shutdown.target"
          "initrd-switch-root.target"
        ];
        unitConfig = {
          DefaultDependencies = false;
          RefuseManualStop = true;
          RequiresMountsFor = concatPath "/sysroot" persistentStoragePath;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "systemd-tmpfiles --create --remove --boot ${configPath}";
          SuccessExitStatus = "DATAERR CANTCREAT";
          ImportCredential = [
            "tmpfiles.*"
            "loging.motd"
            "login.issue"
            "network.hosts"
            "ssh.authorized_keys.root"
          ];
        };
      };

      mkRegularTmpfilesService = onBoot: configPath: persistentStoragePath: restartTrigger: {
        wantedBy = optionals onBoot [ "preservation.target" ];
        requiredBy = optionals (!onBoot) [ "sysinit-reactivation.target" ];
        after = [
          "systemd-sysusers.service"
          "systemd-journald.service"
        ];
        before = [
          "shutdown.target"
        ]
        ++ optionals onBoot [
          "sysinit.target"
          "initrd-switch-root.target"
          "systemd-tmpfiles-setup.service"
          "preservation.target"
        ]
        ++ optionals (!onBoot) [
          "sysinit-reactivation.target"
          "systemd-tmpfiles-resetup.service"
        ];
        conflicts = [
          "shutdown.target"
        ]
        ++ optionals onBoot [
          "initrd-switch-root.target"
        ];
        restartTriggers = optionals (!onBoot) [ restartTrigger ];
        unitConfig = {
          DefaultDependencies = false;
          RefuseManualStop = onBoot;
          RequiresMountsFor = persistentStoragePath;
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "systemd-tmpfiles --create --remove ${optionalString onBoot "--boot"} ${configPath}";
          SuccessExitStatus = "DATAERR CANTCREAT";
          ImportCredential = [
            "tmpfiles.*"
            "loging.motd"
            "login.issue"
            "network.hosts"
            "ssh.authorized_keys.root"
          ];
        };
      };
    in
    {
      passthru.preservation = {
        inherit
          getAllDirectories
          getAllFiles
          getUserDirectories
          getUserFiles
          mkRuleFileContent
          mkRegularMountUnits
          mkInitrdMountUnits
          mkRegularTmpfilesRules
          mkInitrdTmpfilesRules
          mkUserParentClosureTmpfilesRule
          mkInitrdTmpfilesService
          mkRegularTmpfilesService
          ;
      };
    };
}
