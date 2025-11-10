{
  inputs,
  self,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    self.flakeModules.meta
    self.flakeModules.unify
  ];
}
