{
  unify.profiles.system._.misc._.i18n =
    { ... }:
    {
      nixos =
        { ... }:
        {
          i18n = {
            defaultLocale = "C.UTF-8";
            defaultCharset = "UTF-8";
            extraLocales = "all";
          };
        };
    };
}
