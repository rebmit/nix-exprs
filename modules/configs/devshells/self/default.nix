{ __findFile, ... }:

{
  includes = [
    <rebmit/features/devshell/languages/nix>
    <rebmit/features/devshell/languages/shell>
    <rebmit/features/devshell/misc/keep-sorted>
    <rebmit/features/devshell/misc/prettier>
  ];
}
