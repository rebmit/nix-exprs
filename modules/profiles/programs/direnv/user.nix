{
  unify.profiles.programs._.direnv._.user =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/users/username"
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
