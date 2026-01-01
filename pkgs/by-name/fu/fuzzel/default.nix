{
  scopes.default =
    { prev, ... }:
    {
      fuzzel = prev.fuzzel.override {
        svgBackend = "librsvg";
      };
    };
}
