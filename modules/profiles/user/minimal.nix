{
  lib,
  standalone,
  __findFile,
  ...
}:

{
  includes = [
    # keep-sorted start
    <rebmit/features/user/config/username>
    <rebmit/features/user/misc/class>
    <rebmit/features/user/misc/nixpkgs>
    <rebmit/features/user/misc/version>
    # keep-sorted end
  ]
  ++ lib.optionals standalone [
    # keep-sorted start
    <rebmit/profiles/user/nix/common>
    # keep-sorted end
  ];
}
