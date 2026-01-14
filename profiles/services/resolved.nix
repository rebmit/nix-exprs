{
  flake.unify.modules."services/resolved" = {
    nixos = {
      module =
        { ... }:
        {
          services.resolved = {
            enable = true;
            settings.Resolve = {
              LLMNR = false;
              MulticastDNS = false;
            };
          };
        };
    };
  };
}
