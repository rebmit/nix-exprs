{
  perSystem =
    { config, pkgs, ... }:
    {
      pre-commit = {
        check.enable = false;
        settings.package = pkgs.pre-commit;
      };

      devshells.default.devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
    };
}
