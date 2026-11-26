{ inputs, lib, ... }:

{ config, ... }:

{
  options.hosts = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.rebmit.submoduleWith {
        class = "host";
        args = {
          inherit inputs lib;
        };
      }
    );
    default = { };
    description = ''
      Host configurations.
    '';
  };

  config = {
    outputs.hosts = config.hosts;
  };
}
