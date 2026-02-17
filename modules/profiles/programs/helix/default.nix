{
  unify.profiles.programs._.helix =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          environment = {
            systemPackages = [ pkgs.helix ];
            sessionVariables.EDITOR = "hx";
          };
        };

      darwin =
        { pkgs, ... }:
        {
          environment = {
            systemPackages = [ pkgs.helix ];
            variables.EDITOR = "hx";
          };
        };
    };
}
