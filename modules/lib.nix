{ config, ... }:
{
  _module.args.selfLib = config.flake.lib;
}
