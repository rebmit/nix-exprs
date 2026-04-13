{ pkgs, ... }:

{
  modules.devshell =
    { ... }:
    {
      packages = [ pkgs.nixd ];
    };

  modules.treefmt =
    { ... }:
    {
      programs = {
        deadnix = {
          enable = true;
          no-underscore = true;
          no-lambda-arg = true;
          no-lambda-pattern-names = true;
        };

        nixfmt.enable = true;
      };
    };
}
