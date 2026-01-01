let
  pyscard =
    {
      lib,
      buildPythonPackage,
      pcsclite,
      pkg-config,
      pytestCheckHook,
      setuptools,
      stdenv,
      swig,
      source,
    }:

    buildPythonPackage {
      inherit (source) pname version src;

      pyproject = true;

      build-system = [ setuptools ];

      nativeBuildInputs = [ swig ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pkg-config ];

      buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ pcsclite ];

      nativeCheckInputs = [ pytestCheckHook ];

      postPatch = ''
        substituteInPlace pyproject.toml \
          --replace-fail 'requires = ["setuptools","swig"]' 'requires = ["setuptools"]'
      ''
      + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
        substituteInPlace setup.py --replace-fail "pkg-config" "$PKG_CONFIG"
        substituteInPlace src/smartcard/scard/winscarddll.c \
          --replace-fail "libpcsclite.so.1" \
                    "${lib.getLib pcsclite}/lib/libpcsclite${stdenv.hostPlatform.extensions.sharedLibrary}"
      '';

      meta = {
        description = "Smartcard library for python";
        homepage = "https://pyscard.sourceforge.io/";
        changelog = "https://github.com/LudovicRousseau/pyscard/releases/tag/${source.version}";
        license = lib.licenses.lgpl21Plus;
        maintainers = with lib.maintainers; [ rebmit ];
      };
    };
in
{
  scopes.python =
    { final, ... }:
    {
      pyscard_2_2_1 =
        let
          source = {
            pname = "pyscard";
            version = "2.2.1";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "LudovicRousseau";
                repo = "pyscard";
                tag = source.version;
                hash = "sha256-RXCz6Npb/MrykHxtUsYlghCPeTwjDC6s9258iLA7OKs=";
              }
            ) { };
          };
        in
        final.callPackage pyscard { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      python3Packages = {
        inherit (pkgs.python3Packages) pyscard_2_2_1;
      };
    };
}
