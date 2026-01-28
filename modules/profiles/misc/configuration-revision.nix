{ self, ... }:
{
  unify.profiles.misc._.configuration-revision =
    { ... }:
    {
      nixos =
        { ... }:
        {
          system.configurationRevision = self.rev or "dirty";
        };
    };
}
