{
  unify.profiles.home._.programs._.comma =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/preservation"
        "profiles/home/misc/username"
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
