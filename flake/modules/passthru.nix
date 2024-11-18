# Portions of this file are sourced from
# https://github.com/linyinfeng/nur-packages/blob/73fea6901c19df2f480e734a75bc22dbabde3a53/flake-modules/passthru.nix
{ lib, ... }:
{
  options.passthru = lib.mkOption {
    visible = false;
    type = with lib.types; attrsOf unspecified;
  };
}
