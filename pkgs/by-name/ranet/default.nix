{
  lib,
  rustPlatform,
}:

{
  pname ? "ranet",
  version,
  src,
  cargoHash,
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

  meta = {
    description = "Redundant array of networks";
    homepage = "https://github.com/NickCao/ranet";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.linux;
  };
}
