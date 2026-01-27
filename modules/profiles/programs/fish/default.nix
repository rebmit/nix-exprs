{
  unify.profiles.programs._.fish =
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
    };
}
