{ self, ... }:
{
  unify.profiles.misc._.version =
    { ... }:
    {
      nixos =
        { ... }:
        {
          system.configurationRevision = self.rev or "dirty";
        };
    };
}
