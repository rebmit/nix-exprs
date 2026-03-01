{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.home._.misc._.i18n =
    { user, ... }:
    {
      requires = [ "profiles/system/misc/i18n" ];

      contexts.user = {
        options = {
          locale = mkOption {
            type = types.str;
            description = ''
              The locale for this user.
            '';
          };
        };
      };

      homeManager =
        { ... }:
        {
          home.language.base = user.locale;
        };
    };
}
