{
  unify.profiles.services._.nixseparatedebuginfod2 =
    { host, ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/networking/ports"
        # keep-sorted end
      ];

      contexts.host = {
        ports = {
          nixseparatedebuginfod2 = 1949;
        };
      };

      nixos =
        { ... }:
        {
          services.nixseparatedebuginfod2 = {
            enable = true;
            port = host.ports.nixseparatedebuginfod2;
            substituters = [
              "local:"
              "https://cache.nixos.org"
            ];
            cacheExpirationDelay = "1d";
          };

          preservation.preserveAt.cache.directories = [ "/var/cache/private/nixseparatedebuginfod2" ];
        };
    };
}
