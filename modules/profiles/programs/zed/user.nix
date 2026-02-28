{
  unify.profiles.programs._.zed._.user =
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
