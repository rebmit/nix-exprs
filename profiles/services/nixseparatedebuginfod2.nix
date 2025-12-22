{ meta, ... }:
{
  meta.ports = {
    nixseparatedebuginfod2 = 1949;
  };

  flake.unify.modules."services/nixseparatedebuginfod2" = {
    nixos = {
      meta = {
        requires = [ "imports/preservation" ];
      };

      module =
        { ... }:
        {
          services.nixseparatedebuginfod2 = {
            enable = true;
            port = meta.ports.nixseparatedebuginfod2;
            substituters = [
              "local:"
              "https://cache.nixos.org"
            ];
            cacheExpirationDelay = "1d";
          };

          preservation.preserveAt.cache.directories = [ "/var/cache/private/nixseparatedebuginfod2" ];
        };
    };
  };
}
