{
  unify.modules."system/i18n" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        i18n = {
          defaultLocale = "C.UTF-8";
          defaultCharset = "UTF-8";
          extraLocales = [
            # keep-sorted start
            "en_HK.UTF-8/UTF-8"
            "en_US.UTF-8/UTF-8"
            "zh_CN.UTF-8/UTF-8"
            "zh_HK.UTF-8/UTF-8"
            # keep-sorted end
          ];
        };
      };
    };
  };
}
