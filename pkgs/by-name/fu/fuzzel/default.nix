{
  scopes.default =
    { prev, ... }:
    {
      fuzzel = prev.fuzzel.override {
        svgBackend = "librsvg";
      };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) fuzzel;
    };
}
