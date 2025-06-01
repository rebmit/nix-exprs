{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  installShellFiles,
  procps,
}:

python3Packages.buildPythonPackage {
  pname = "yubikey-manager";
  version = "5.4.0-unstable-2025-03-26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "canokeys";
    repo = "yubikey-manager";
    rev = "088ab31778d94a5447b4ffa98529d4dafde618f1";
    hash = "sha256-fqrMCF1PSOaQ9K4eFGs9w6wjUGuHp+GwO/PBFh6xKSM=";
  };

  postPatch = ''
    substituteInPlace "ykman/pcsc/__init__.py" \
      --replace 'pkill' '${if stdenv.hostPlatform.isLinux then procps else "/usr"}/bin/pkill'
  '';

  nativeBuildInputs = with python3Packages; [
    poetry-core
    installShellFiles
  ];

  propagatedBuildInputs = with python3Packages; [
    cryptography
    pyscard
    fido2
    click
    keyring
  ];

  pythonRelaxDeps = [
    "keyring"
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    makefun
  ];

  meta = with lib; {
    description = "Command line tool for configuring any YubiKey over all USB transports";
    homepage = "https://github.com/canokeys/yubikey-manager";
    license = licenses.bsd2;
    platforms = platforms.unix;
    mainProgram = "ckman";
  };
}
