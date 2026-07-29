{
  mtxclient,
  fetchFromGitHub,
  nix-update-script,
}:

mtxclient.overrideAttrs (oldAttrs: {
  version = "0.10.1-unstable-2026-03-02";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "mtxclient";
    rev = "f5766cb53c244a808b7e512c7b83b3942fb67834";
    hash = "sha256-5LapoeXRiRi4tSpFvcVu4Z6+aDIz43UBoDU1Rx2y8TA=";
  };

  passthru = (oldAttrs.passthru or { }) // {
    updateScript = nix-update-script {
      extraArgs = [
        "--override-filename"
        "pkgs/by-name/mt/mtxclient_unstable/package.nix"
        "--version"
        "branch=master"
      ];
    };
  };
})
