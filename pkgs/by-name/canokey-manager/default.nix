let
  canokey-manager =
    {
      lib,
      stdenv,
      python3Packages,
      installShellFiles,
      procps,
      source,
    }:

    python3Packages.buildPythonPackage {
      inherit (source) pname version src;
      pyproject = true;

      postPatch = ''
        substituteInPlace "ykman/pcsc/__init__.py" \
          --replace-fail 'pkill' '${if stdenv.hostPlatform.isLinux then procps else "/usr"}/bin/pkill'
      '';

      nativeBuildInputs = with python3Packages; [
        poetry-core
        installShellFiles
      ];

      propagatedBuildInputs = with python3Packages; [
        cryptography
        pyscard_2_2_1
        fido2
        click
        keyring
      ];

      pythonRelaxDeps = [
        "cryptography"
        "fido2"
        "keyring"
      ];

      nativeCheckInputs = with python3Packages; [
        pytestCheckHook
        makefun
      ];

      meta = {
        description = "Command line tool for configuring any CanoKey over all USB transports";
        homepage = "https://github.com/canokeys/yubikey-manager";
        license = lib.licenses.bsd2;
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.unix;
        mainProgram = "ckman";
      };
    };
in
{
  overlays.default =
    { final, ... }:
    {
      canokey-manager =
        let
          source = {
            pname = "canokey-manager";
            version = "5.4.0-unstable-2025-03-26";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "canokeys";
                repo = "yubikey-manager";
                rev = "088ab31778d94a5447b4ffa98529d4dafde618f1";
                hash = "sha256-fqrMCF1PSOaQ9K4eFGs9w6wjUGuHp+GwO/PBFh6xKSM=";
              }
            ) { };
          };
        in
        final.callPackage canokey-manager { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) canokey-manager;
      };
    };
}
