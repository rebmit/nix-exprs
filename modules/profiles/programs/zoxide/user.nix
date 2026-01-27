{
  unify.profiles.programs._.zoxide._.user =
    { user, ... }:
    {
      contexts = [ "user" ];

      requires = [ "features/preservation" ];

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
