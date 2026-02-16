{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.misc._.i18n._.user =
    { user, ... }:
    {
      requires = [ "profiles/misc/i18n" ];

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
