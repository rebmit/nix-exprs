{
  unify.profiles.nix._.user =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/users/username"
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
