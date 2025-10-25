# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/tests/activation/nixos-init.nix (MIT License)
{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks."profiles/immutable/nixos-init" = pkgs.nixosTest {
        name = "immutable-nixos-init";

        nodes.machine =
          { modulesPath, ... }:
          {
            imports = [
              config.flake.modules.nixos.immutable
              "${modulesPath}/profiles/perlless.nix"
            ];

            system.nixos-init.enable = true;
            networking.useNetworkd = true;

            environment.etc."oldfile".text = "old-generation";

            specialisation.new-generation.configuration = {
              environment.etc = {
                "oldfile".text = mkForce "new-generation";
                "newfile".text = "new-generation";
              };
            };
          };

        testScript =
          # python
          ''
            machine.start(allow_reboot=True)
            machine.wait_for_unit("default.target")

            with subtest("Initial /etc contents are in place"):
              actual   = machine.succeed("cat /etc/oldfile")
              expected = "old-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch")

            machine.succeed("/run/current-system/specialisation/new-generation/bin/switch-to-configuration switch")

            with subtest("Updated /etc contents are applied after switch"):
              actual   = machine.succeed("cat /etc/oldfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch after switch")

              actual   = machine.succeed("cat /etc/newfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/newfile content mismatch after switch")

            machine.shutdown()
          '';
      };
    };
}
