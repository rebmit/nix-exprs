{ self, ... }:
{
  unify.profiles.misc._.configuration-revision =
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
