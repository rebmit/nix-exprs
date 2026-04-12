{
  unify.features.home._.programs._.direnv =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/home/misc/username"
        "features/system/preservation"
        # keep-sorted end
      ];

      contexts.user = { };

      homeManager =
        { ... }:
        {
          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt = {
            state.users.${user.userName}.directories = [ ".local/share/direnv" ];
          };
        };
    };
}
