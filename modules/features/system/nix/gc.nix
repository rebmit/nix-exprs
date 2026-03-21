{
  unify.features.system._.nix._.gc =
    { ... }:
    {
      nixos =
        { ... }:
        {
          nix = {
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 14d";
            };

            settings.min-free = 1024 * 1024 * 1024; # bytes
          };
        };

      darwin =
        { ... }:
        {
          nix = {
            gc = {
              automatic = true;
              interval = [
                {
                  Weekday = 7;
                  Hour = 3;
                  Minute = 15;
                }
              ];
              options = "--delete-older-than 14d";
            };

            settings.min-free = 1024 * 1024 * 1024; # bytes
          };
        };
    };
}
