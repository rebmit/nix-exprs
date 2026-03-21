{
  unify.features.home._.programs._.yazi =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.yazi = {
            enable = true;
            shellWrapperName = "ra";
            settings = {
              mgr = {
                sort_by = "natural";
                linemode = "size";
              };
              preview = {
                tab_size = 2;
                max_width = 1000;
                max_height = 1000;
              };
            };
          };
        };
    };
}
