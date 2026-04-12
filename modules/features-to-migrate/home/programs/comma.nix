{
  unify.features.home._.programs._.comma =
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
