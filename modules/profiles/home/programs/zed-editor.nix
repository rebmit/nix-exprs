{
  unify.profiles.home._.programs._.zed-editor =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.zed-editor = {
            enable = true;
            extensions = [ "nix" ];
            userSettings = {
              helix_mode = true;
              telemetry = {
                diagnostics = false;
                metrics = false;
              };
            };
          };
        };
    };
}
