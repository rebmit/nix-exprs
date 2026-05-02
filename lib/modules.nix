{ lib, ... }:

let
  lattice =
    {
      # Providers to include.
      includes ? [ ],

      # Providers to exclude.
      excludes ? [ ],

      # Names of configs that are allowed to be defined internally.
      internalConfigs ? [ ],

      # Fully evaluated config instances provided externally.
      externalConfigs ? { },

      # Inputs passed to providers.
      inputs ? { },

      # Registry mapping names to paths.
      registry ? { },
    }:
    let
      configModule =
        { ... }:
        {
          _file = ./modules.nix;

          options = {
            __key__ = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                An optional key used to distinguish different realizations of the same config.
              '';
            };
          };
        };

      providerModule =
        { ... }:
        {
          _file = ./modules.nix;

          options = {
            configs =
              lib.genAttrs internalConfigs (
                name:
                lib.mkOption {
                  type = lib.types.deferredModuleWith {
                    staticModules = [ configModule ];
                  };
                  default = { };
                  apply = m: (lib.evalModules { modules = [ m ]; }).config;
                  description = ''
                    Configuration for ${name} evaluated from module definitions.

                    This value is exposed as an argument to the provider and can be
                    used to construct modules.
                  '';
                }
              )
              // lib.mapAttrs (
                name: value:
                lib.mkOption {
                  type = lib.types.deferredModuleWith {
                    staticModules = [ configModule ];
                  };
                  default = { };
                  description = ''
                    Configuration for ${name} provided externally.

                    Definitions in the module system are still collected but ignored
                    in favor of the external configuration.
                  '';
                }
              ) externalConfigs;

            modules = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.deferredModule;
              default = { };
              description = ''
                Deferred module definitions per entry.
              '';
            };
          };
        };

      finalInputs =
        assert lib.all (name: inputs ? ${name} -> throw "'${name}' cannot be used as the name of an input")
          [
            "registry"
            "__findFile"
          ];
        inputs
        // {
          inherit registry __findFile;
        };

      __findFile =
        _: name:
        let
          parts = lib.splitString "/" name;

          head = lib.head parts;
          tail = "/" + lib.concatStringsSep "/" (lib.tail parts);

          path = registry.${head} + tail;
          resolved = if lib.pathIsDirectory path then path else path + ".nix";
        in
        lib.addErrorContext "while evaluating provider path from `<${name}>`:" resolved;

      unifyProvider =
        m: fallbackFile: fallbackKey:
        if lib.isAttrs m || lib.isFunction m then
          { config, ... }:
          let
            provider = lib.toFunction ((lib.toFunction m) finalInputs);
            provider' = provider requiredArgs;

            allArgs = {
              inherit (config) modules;
            }
            // lib.getAttrs internalConfigs config.configs
            // externalConfigs;

            requiredArgs = lib.mapAttrs (
              name: _:
              lib.addErrorContext ''while evaluating the lattice provider argument `${name}' in "${key}":''
                allArgs.${name}
            ) (lib.functionArgs provider);

            key = provider'.key or fallbackKey;
            file = provider'.file or fallbackFile;

            keys = lib.mapAttrs (_: v: v.__key__) (lib.removeAttrs requiredArgs [ "modules" ]);

            invalid = lib.subtractLists [ "file" "key" "includes" "excludes" "configs" "modules" ] (
              lib.attrNames provider'
            );

            configs = lib.mapAttrs (n: v: {
              _class = n;
              _file = file;
              key = key;
              imports = [ v ];
            }) (provider'.configs or { });

            modules = lib.mapAttrs (n: v: {
              _class = n;
              _file = file;
              key = "${key}@${lib.hashString "sha256" (lib.toJSON keys)}";
              imports = [ v ];
            }) (provider'.modules or { });
          in
          assert
            lib.isAttrs provider' && invalid == [ ]
            || throw "invalid provider, unsupported attributes ${toString invalid}";
          {
            _class = "provider";
            _file = file;
            key = key;
            imports =
              lib.imap (n: m: loadProvider m file "${key}:anon-${toString n}")
                provider'.includes or [ ];
            disabledModules = provider'.excludes or [ ];
            config = {
              inherit configs modules;
            };
          }
        else
          throw "invalid provider, expected attrs or function, but got ${builtins.typeOf m}";

      loadProvider =
        m: fallbackFile: fallbackKey:
        if lib.isFunction m || lib.isAttrs m then
          unifyProvider m fallbackFile fallbackKey
        else if lib.isPath m then
          let
            path = lib.filesystem.resolveDefaultNix m;
            provider = import path;
          in
          unifyProvider provider path (toString path)
        else
          throw "invalid provider, expected path, attrs or function, but got ${builtins.typeOf m}";
    in
    (lib.evalModules {
      modules = [
        providerModule
        {
          imports = lib.imap (
            n: m: loadProvider m "<unknown-lattice>" "<unknown-lattice>:anon-${toString n}"
          ) includes;
          disabledModules = excludes;
        }
      ];
    }).config;
in
{
  inherit
    lattice
    ;
}
