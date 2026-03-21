{
  unify.features.home._.nix =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/home/misc/username"
        "features/system/preservation"
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
