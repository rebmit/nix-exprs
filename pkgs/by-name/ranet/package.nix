{
  pname ? "ranet",
  version,
  src,
  cargoHash,
  nixUpdateExtraArgs ? [ ],
}:

{
  lib,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  inherit
    pname
    version
    src
    cargoHash
    ;

  checkFlags = [
    "--skip=address::test::remote"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = nixUpdateExtraArgs;
    };
  };

  meta = {
    description = "Redundant array of networks";
    homepage = "https://github.com/NickCao/ranet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.linux;
  };
}
