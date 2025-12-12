{
  flake.unify.modules."services/user/ssh-agent" = {
    homeManager = {
      module =
        { ... }:
        {
          services.ssh-agent.enable = true;
        };
    };
  };
}
