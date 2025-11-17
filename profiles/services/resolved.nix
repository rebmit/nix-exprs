{
  flake.unify.modules."services/resolved" = {
    nixos = {
      module =
        { ... }:
        {
          services.resolved = {
            enable = true;
            llmnr = "false";
            extraConfig = ''
              MulticastDNS=off
              DNSStubListener=no
            '';
          };
        };
    };
  };
}
