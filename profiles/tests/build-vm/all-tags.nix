{
  config,
  lib,
  extendModules,
  ...
}:
let
  inherit (lib.attrsets)
    filterAttrs
    hasAttr
    mapAttrsToList
    nameValuePair
    listToAttrs
    ;
  inherit (lib.lists) flatten unique;
  inherit (lib.modules) mkOverride;
  inherit (lib.trivial) pipe;

  nixosTags = pipe config.unify.modules [
    (filterAttrs (_: hasAttr "nixos"))
    (mapAttrsToList (_: v: v.nixos.meta.tags))
    flatten
    unique
  ];

  nixosTests =
    system:
    pipe nixosTags [
      (map (
        tag:
        nameValuePair "profiles/build-vm/nixos/tags/${tag}"
          (extendModules {
            modules = [
              {
                unify.hosts.nixos.test = mkOverride 5 {
                  meta.tags = [ tag ];
                  inherit system;
                  module =
                    { pkgs, unify, ... }:
                    {
                      system.stateVersion = "25.11";
                      services.getty.autologinUser = "root";
                      users.allowNoPasswordLogin = true;
                      environment.etc."meta".source = (pkgs.formats.json { }).generate "meta" unify.meta;
                    };
                };
              }
            ];
          }).config.flake.nixosConfigurations.test.config.system.build.vm
      ))
      listToAttrs
    ];
in
{
  perSystem =
    { system, ... }:
    {
      checks = nixosTests system;
    };
}
