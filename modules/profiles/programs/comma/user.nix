{
  unify.profiles.programs._.comma._.user =
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
        { pkgs, ... }:
        {
          home.packages = [ pkgs.comma-with-db ];
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt = {
            state.users.${user.userName}.directories = [ ".local/state/comma" ];
          };
        };
    };
}
