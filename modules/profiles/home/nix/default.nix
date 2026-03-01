{
  unify.profiles.home._.nix =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/preservation"
        "profiles/home/misc/username"
        # keep-sorted end
      ];

      contexts.user = { };

      nixos =
        { ... }:
        {
          preservation.preserveAt = {
            cache.users.${user.userName}.directories = [ ".cache/nix" ];
            state.users.${user.userName}.directories = [
              ".local/share/nix"
              ".local/state/nix"
            ];
          };
        };
    };
}
