{ config, ... }:
{
  overlays.default =
    { prev, ... }:
    {
      pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
        config.overlays.python
      ];
    };
}
