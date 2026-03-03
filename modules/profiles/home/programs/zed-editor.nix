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
              languages = {
                Nix = {
                  language_servers = [
                    "!nil"
                    "nixd"
                  ];
                };
              };
              relative_line_numbers = "enabled";
              telemetry = {
                diagnostics = false;
                metrics = false;
              };
              theme = {
                mode = "system";
                light = "Adwaita Light";
                dark = "Adwaita Dark";
              };
              which_key = {
                enabled = true;
                delay_ms = 200;
              };
              # keep-sorted end
            };
          };
        };
    };
}
