{
  lib,
  stdenv,
  python3Packages,
  installShellFiles,
  procps,
}:

{
  pname ? "canokey-manager",
  version,
  src,
}:

python3Packages.buildPythonPackage {
  inherit pname version src;
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
}
