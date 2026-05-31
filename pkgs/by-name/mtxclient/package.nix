{
  pname ? "mtxclient",
  version,
  src,
  nixUpdateExtraArgs ? [ ],
}:

{
  lib,
  stdenv,
  cmake,
  pkg-config,
  coeurl,
  curl,
  libevent,
  nlohmann_json,
  olm,
  openssl,
  re2,
  spdlog,
  gtest,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit pname version src;

  patches = [
    ./remove-network-tests.patch
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_LIB_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "BUILD_LIB_EXAMPLES" false)
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    coeurl
    curl
    libevent
    nlohmann_json
    olm
    openssl
    re2
    spdlog
  ];

  checkInputs = [ gtest ];

  doCheck = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = nixUpdateExtraArgs;
    };
  };

  meta = {
    description = "Client API library for the Matrix protocol";
    homepage = "https://github.com/Nheko-Reborn/mtxclient";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.all;
  };
})
