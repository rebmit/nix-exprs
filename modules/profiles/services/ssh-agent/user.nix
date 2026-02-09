{
  unify.profiles.services._.ssh-agent._.user =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          services.ssh-agent.enable = true;
        };
    };
}
