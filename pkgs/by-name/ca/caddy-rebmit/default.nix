let
  caddy-rebmit =
    { caddy }:
    caddy.withPlugins {
      hash = "sha256-ujjlyTBJqrEoSFDxb14rWh7VDCaSmhqnC+/BqYgbMgY=";
      plugins = [
        "github.com/mholt/caddy-l4@v0.0.0-20251209130418-1a3490ef786a"
      ];
    };
in
{
  scopes.default =
    { final, ... }:
    {
      caddy-rebmit = final.callPackage caddy-rebmit { };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) caddy-rebmit;
    };
}
