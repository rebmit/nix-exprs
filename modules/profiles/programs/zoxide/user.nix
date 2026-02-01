{
  unify.profiles.programs._.zoxide._.user =
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
          programs.zoxide.enable = true;
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt = {
            state.users.${user.userName}.directories = [ ".local/share/zoxide" ];
          };
        };
    };
}
