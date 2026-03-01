{
  unify.profiles.home._.programs._.direnv =
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
