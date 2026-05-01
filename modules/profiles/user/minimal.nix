{ __findFile, ... }:

{
  includes = [
    <rebmit/features/user/config/nix/settings>
    <rebmit/features/user/config/username>
    <rebmit/features/user/misc/class>
    <rebmit/features/user/misc/nixpkgs>
    <rebmit/features/user/misc/version>
  ];
}
