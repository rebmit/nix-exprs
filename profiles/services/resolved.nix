{
  unify.modules."services/resolved" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module = _: {
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
