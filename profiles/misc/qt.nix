{
  flake.unify.modules."misc/qt" = {
    homeManager = {
      module =
        { ... }:
        {
          home.sessionVariables = {
            QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
          };
        };
    };
  };
}
