{
  unify.profiles.programs._.zoxide._.user =
    { user, ... }:
    {
      requires = [ "features/preservation" ];

      contexts.user = { };

      homeManager =
        { ... }:
        {
          programs.zoxide.enable = true;
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt.state.users.${user.name}.directories = [ ".local/share/zoxide" ];
        };
    };
}
