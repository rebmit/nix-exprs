{ lib, ... }:

{ options, ... }:

{
  options.outputs = {
    shell = lib.mkOption {
      type = lib.types.raw;
      default = throw ''
        `${options.outputs.shell}` is used but is not set.

        Consider enabling an integration that provides it (e.g. the devshell integration).
      '';
      description = ''
        Shell artifact built from the dev configuration.
      '';
    };

    formatter = lib.mkOption {
      type = lib.types.raw;
      default = throw ''
        `${options.outputs.formatter}` is used but is not set.

        Consider enabling an integration that provides it (e.g. the treefmt integration).
      '';
      description = ''
        Formatter artifact built from the dev configuration.
      '';
    };
  };
}
