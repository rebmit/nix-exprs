{
  unify.profiles.home._.programs._.zed-editor =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.zed-editor = {
            enable = true;
            extensions = [
              # keep-sorted start
              "adwaita"
              "nix"
              # keep-sorted end
            ];
            userSettings = {
              # keep-sorted start block=yes
              helix_mode = true;
              telemetry = {
                diagnostics = false;
                metrics = false;
              };
              theme = {
                mode = "system";
                light = "Adwaita Light";
                dark = "Adwaita Dark";
              };
              # keep-sorted end
            };
          };
        };
    };
}
