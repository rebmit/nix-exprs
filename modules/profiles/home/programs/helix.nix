{
  unify.profiles.home._.programs._.helix =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.helix = {
            enable = true;
            defaultEditor = true;
            settings = {
              editor = {
                line-number = "relative";
                cursorline = true;
                bufferline = "multiple";
                color-modes = true;
                lsp.display-messages = true;
                cursor-shape = {
                  insert = "bar";
                  normal = "block";
                  select = "underline";
                };
                indent-guides.render = true;
              };
              theme = "adwaita-light";
              keys = {
                normal = {
                  esc = [
                    "keep_primary_selection"
                    "collapse_selection"
                  ];
                  S = ":w";
                  Q = ":q";
                };
              };
            };
          };
        };
    };
}
