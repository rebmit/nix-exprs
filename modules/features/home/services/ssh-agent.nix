{
  unify.features.home._.services._.ssh-agent =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          services.ssh-agent.enable = true;
        };
    };
}
