final: prev:

let
  inherit
    (final.callPackage (
      {
        fetchFromGitHub,
      }@args:
      args
    ) { })
    fetchFromGitHub
    ;
in
{
  # keep-sorted start block=yes newline_separated=yes
  pyscard_2_2_1 =
    let
      source = {
        version = "2.2.1";
        src = fetchFromGitHub {
          owner = "LudovicRousseau";
          repo = "pyscard";
          tag = source.version;
          hash = "sha256-RXCz6Npb/MrykHxtUsYlghCPeTwjDC6s9258iLA7OKs=";
        };
      };
    in
    final.callPackage ../development/python-modules/pyscard { } source;
  # keep-sorted end
}
