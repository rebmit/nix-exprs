# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/tests/userborn-immutable-etc.nix (MIT License)
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/tests/basic.nix (MIT License)
{
  self,
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkForce;
  inherit (lib.trivial) pipe;

  immutable = {
    imports = pipe config.unify.modules [
      (config.unify.lib.collectModulesForHost "nixos" { tags = [ "immutable" ]; })
      (map (n: self.modules.nixos.${n}))
    ];
  };
in
{
  perSystem =
    { pkgs, ... }:
    let
      hashedPassword = "$y$j9T$fWWcA1PsU7r/WTleSXFRi0$oFfktzz2S.57dHqLImfUB5eTzxCQYYsHfE.5QWUj7g6";
    in
    {
      checks."profiles/immutable" = pkgs.testers.nixosTest {
        name = "immutable";

        nodes.machine =
          { ... }:
          {
            imports = [ immutable ];

            testing.initrdBackdoor = true;

            networking.useNetworkd = true;

            users.users.rebmit = {
              inherit hashedPassword;
              isNormalUser = true;
            };

            environment.etc."oldfile".text = "old-generation";

            specialisation.new-generation.configuration = {
              environment.etc = {
                "oldfile".text = mkForce "new-generation";
                "newfile".text = "new-generation";
              };

              users.users.timber = {
                inherit hashedPassword;
                isNormalUser = true;
              };
              users.users.rebmit.enable = false;
            };
          };

        passthru = { inherit immutable; };

        testScript =
          # python
          ''
            machine.start(allow_reboot=True)
            machine.switch_root()
            machine.wait_for_unit("default.target")

            # with subtest("Initial boot meets ConditionFirstBoot"):
            #   machine.require_unit_state("first-boot-complete.target","active")

            with subtest("User rebmit is enabled"):
              actual   = machine.succeed("getent shadow rebmit")
              expected = "${hashedPassword}"
              t.assertIn(expected, actual, "user rebmit password hash mismatch")

            with subtest("Initial /etc contents are in place"):
              actual   = machine.succeed("cat /etc/oldfile")
              expected = "old-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch")

            machine.succeed("/run/current-system/specialisation/new-generation/bin/switch-to-configuration switch")

            with subtest("User rebmit is disabled after switch"):
              actual   = machine.succeed("getent shadow rebmit")
              expected = "!*"
              t.assertIn(expected, actual, "user rebmit should be disabled")

            with subtest("User timber is enabled after switch"):
              actual   = machine.succeed("getent shadow timber")
              expected = "${hashedPassword}"
              t.assertIn(expected, actual, "user timber password hash mismatch")

            with subtest("Updated /etc contents are applied after switch"):
              actual   = machine.succeed("cat /etc/oldfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch after switch")

              actual   = machine.succeed("cat /etc/newfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/newfile content mismatch after switch")

            with subtest("/etc/machine-id is preserved across reboots"):
              machine_id = machine.succeed("cat /etc/machine-id")

              machine.reboot()
              machine.wait_for_unit("default.target")

              initrd_machine_id = machine.succeed("cat /sysroot/var/lib/nixos/systemd/machine-id")
              t.assertEqual(initrd_machine_id, machine_id, "machine id changed")

              machine.switch_root()
              machine.wait_for_unit("default.target")

              machine.succeed("test -s /etc/machine-id")
              new_machine_id = machine.succeed("cat /etc/machine-id")
              t.assertEqual(new_machine_id, machine_id, "machine id changed")

            with subtest("User timber is disabled after reboot"):
              actual   = machine.succeed("getent shadow timber")
              expected = "!*"
              t.assertIn(expected, actual, "user timber should be disabled after reboot")

            # with subtest("Second boot does not meet ConditionFirstBoot"):
            #   machine.require_unit_state("first-boot-complete.target", "inactive")

            machine.shutdown()
          '';
      };
    };
}
