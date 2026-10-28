{ lib, ... }:

{
  args ? { },
  class ? null,
  baseModules ? if class == null then [ ] else import ../modules/${class}/module-list.nix,
  modules ? [ ],
  ...
}@evalModulesArgs:

let
  normalize =
    m:
    let
      loaded = lib.toFunction (if builtins.isPath m then import m else m) args;
    in
    if builtins.isPath m then
      {
        _file = toString m;
        key = toString m;
        imports = [ loaded ];
      }
    else
      loaded;
in
lib.evalModules (
  lib.removeAttrs evalModulesArgs [
    "args"
    "baseModules"
  ]
  // {
    inherit class;
    modules = [
      {
        options._ = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.deferredModule;
          default = { };
        };
      }
    ]
    ++ map normalize (baseModules ++ modules);
  }
)
