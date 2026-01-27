{
  unify.profiles.programs._.comma._.user =
    { user, ... }:
    {
      contexts = [ "user" ];

      requires = [ "features/preservation" ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.comma-with-db ];
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt.state.users.${user.name}.directories = [ ".local/state/comma" ];
        };
    };
}
