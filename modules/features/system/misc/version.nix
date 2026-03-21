{ self, ... }:
{
  unify.features.system._.misc._.version =
    { ... }:
    let
      revision = self.rev or "dirty";
    in
    {
      nixos =
        { ... }:
        {
          system.configurationRevision = revision;
        };

      darwin =
        { ... }:
        {
          system.configurationRevision = revision;
        };
    };
}
