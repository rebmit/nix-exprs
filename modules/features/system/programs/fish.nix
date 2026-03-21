{
  unify.features.system._.programs._.fish =
    { ... }:
    {
      nixos =
        { ... }:
        {
          programs.fish = {
            enable = true;
            useBabelfish = true;
            generateCompletions = false;
          };
        };

      darwin =
        { ... }:
        {
          programs.fish = {
            enable = true;
            useBabelfish = true;
          };
        };
    };
}
