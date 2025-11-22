{ self, ... }:
{
  flake.meta.ports = {
    nixseparatedebuginfod2 = 1949;
  };

  flake.unify.modules."services/nixseparatedebuginfod2" = {
    nixos = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          services.nixseparatedebuginfod2 = {
            enable = true;
            port = self.meta.ports.nixseparatedebuginfod2;
            substituters = [
              "local:"
              "https://cache.nixos.org"
            ];
            cacheExpirationDelay = "1d";
          };

          preservation.directories = [ "/var/cache/private/nixseparatedebuginfod2" ];
        };
    };
  };
}
