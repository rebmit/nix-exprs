{ lib, flake-parts-lib, ... }:
let
  inherit (lib) types;
  inherit (lib.asserts) assertMsg;
  inherit (lib.attrsets) foldlAttrs filterAttrs attrNames;
  inherit (lib.lists) length;
  inherit (lib.options) mkOption;
  inherit (lib.strings) optionalString concatMapStringsSep concatStringsSep;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  options.flake = mkSubmoduleOptions {
    meta = mkSubmoduleOptions {
      ports = mkOption {
        type = types.attrsOf types.port;
        default = { };
        apply =
          ports:
          let
            reverse = foldlAttrs (
              acc: name: value:
              acc
              // {
                ${toString value} = (acc.${toString value} or [ ] ++ [ name ]);
              }
            ) { } ports;

            duplicates = filterAttrs (_name: value: length value > 1) reverse;

            collisionMsg =
              optionalString (duplicates != { }) "Port collision detected:\n"
              + concatMapStringsSep "\n" (port: "  ${port}: ${concatStringsSep ", " duplicates.${port}}") (
                attrNames duplicates
              );
          in
          assert assertMsg (duplicates == { }) collisionMsg;
          ports;
        description = ''
          A mapping of network ports, each identified by a unique name.
        '';
      };
    };
  };
}
