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
            configs = lib.genAttrs internalConfigs (
              name:
              lib.mkOption {
                type = lib.types.deferredModuleWith {
                  staticModules = [ configModule ];
                };
                default = { };
                apply = m: (lib.evalModules { modules = [ m ]; }).config;
                description = ''
                  Evaluated configuration for ${name}.

                  This value is exposed as an argument to the provider and can be
                  used to construct modules.
                '';
              }
            );

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
        assert lib.all (
          name: inputs ? ${name} -> throw "'${name}' cannot be used as the name of an input"
        ) [ "registry" ];
        inputs
        // {
          inherit registry;
        };

      __findFile =
        _: name:
        let
          parts = lib.splitString "/" name;

          head = lib.head parts;
          tail = "/" + lib.concatStringsSep "/" (lib.tail parts);

          path = registry.${head} + tail;
          resolved = if lib.pathIsDirectory path then path + "/default.nix" else path + ".nix";
        in
        lib.addErrorContext "while evaluating provider path from `<${name}>`:" resolved;

      loadProvider =
        m:
        if lib.isPath m then
          { config, ... }:
          let
            provider = scopedImport { inherit __findFile; } m;

            provider' = lib.toFunction ((lib.toFunction provider) finalInputs);
            provider'' = provider' requiredArgs;

            allArgs = {
              inherit (config) modules;
            }
            // config.configs
            // externalConfigs;

            requiredArgs = lib.mapAttrs (
              name: _:
              lib.addErrorContext ''while evaluating the lattice provider argument `${name}' in "${toString m}":''
                allArgs.${name}
            ) (lib.functionArgs provider');

            invalid = lib.subtractLists [ "includes" "excludes" "configs" "modules" ] (
              lib.attrNames provider''
            );
          in
          assert
            lib.isAttrs provider'' && invalid == [ ]
            || throw "invalid provider, unsupported attributes ${toString invalid}";
          let
            keys = lib.mapAttrs (_: v: v.__key__) (lib.removeAttrs requiredArgs [ "modules" ]);

            configs = lib.mapAttrs (n: v: {
              _class = n;
              _file = m;
              key = toString m;
              imports = [ v ];
            }) (provider''.configs or { });

            modules = lib.mapAttrs (n: v: {
              _class = n;
              _file = m;
              key = "${toString m}@${lib.hashString "sha256" (lib.toJSON keys)}";
              imports = [ v ];
            }) (provider''.modules or { });
          in
          {
            _class = "provider";
            _file = m;
            key = toString m;
            imports = map loadProvider provider''.includes or [ ];
            disabledModules = provider''.excludes or [ ];
            config = {
              inherit configs modules;
            };
          }
        else
          throw "invalid provider, expected path, but got ${builtins.typeOf m}";
    in
    (lib.evalModules {
      modules = [
        providerModule
        {
          imports = map loadProvider includes;
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
