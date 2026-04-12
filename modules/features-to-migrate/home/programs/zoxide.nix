{
  unify.features.home._.programs._.zoxide =
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
