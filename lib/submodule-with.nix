{ self, lib, ... }:

{
  args ? { },
  class ? null,
  modules ? [ ],
  shorthandOnlyDefinesConfig ? false,
  ...
}@submoduleWithArgs:

let
  eval =
    loc: defs:
    self.evalModules (
      removeAttrs submoduleWithArgs [
        "shorthandOnlyDefinesConfig"
      ]
      // {
        prefix = loc;
        modules = [
          { _module.args.name = lib.mkOptionDefault (lib.last ([ "‹name›" ] ++ loc)); }
        ]
        ++ modules
        ++ map (
          def:
          if builtins.isAttrs def.value && shorthandOnlyDefinesConfig then
            {
              _file = def.file;
              config = def.value;
            }
          else
            {
              _file = def.file;
              imports = [ def.value ];
            }
        ) defs;
      }
    );
in
lib.types.mkOptionType {
  name = "submodule";
  check = x: lib.isAttrs x || lib.isFunction x || lib.types.path.check x;
  merge = loc: defs: (eval loc defs).config;
  emptyValue = {
    value = (eval [ ] [ ]).config;
  };
  getSubOptions = prefix: (eval prefix [ ]).options;
}
