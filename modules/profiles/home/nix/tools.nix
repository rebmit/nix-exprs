{
  unify.profiles.home._.nix._.tools =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = builtins.attrValues {
            inherit (pkgs)
              # keep-sorted start
              dix
              nix-tree
              nix-update
              nixpkgs-review
              # keep-sorted end
              ;
          };
        };
    };
}
