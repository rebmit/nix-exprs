{
  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      devshells.default = {
        packages = with pkgs; [
          just
        ];
        env = [
          (lib.nameValuePair "DEVSHELL_NO_MOTD" 1)
        ];
        devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
      };
    };
}
