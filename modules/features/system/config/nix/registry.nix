{ __findFile, ... }:

{ host, ... }:

{
  includes = [
    ./.

    <rebmit/features/system/misc/nixpkgs>
  ];

  configs.host =
    { ... }:
    {
      nix = {
        nixPath = [
          "nixpkgs=flake:nixpkgs"
        ];

        registry = {
          nixpkgs = {
            to = {
              type = "path";
              path = host.nixpkgs.path;
            };
          };
        };
      };
    };
}
