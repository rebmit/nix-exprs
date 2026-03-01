{
  unify.profiles.home._.programs._.zoxide =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/home/misc/username"
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
