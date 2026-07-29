{
  nheko,
  lib,
  fetchFromGitHub,
  mtxclient_unstable,
  nix-update-script,
}:

(nheko.override { mtxclient = mtxclient_unstable; }).overrideAttrs (oldAttrs: {
  version = "0.12.1-unstable-2026-05-08";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "90ff9c6f36dd9df9e0e23212c34b83ec61772bba";
    hash = "sha256-Zyvfxuk77FYBYwPJykK6YBnnCLG1BeN6jJ5gcDA5Go4=";
  };

  patches = lib.filter (
    p:
    let
      b = p.name or null;
    in
    b != "2769642d3c7bd3c0d830b2f18ef6b3bf6a710bf4.patch"
    && b != "af2ca72030deb14a920a888e807dc732d93e3714.patch"
  ) oldAttrs.patches;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--override-filename"
        "pkgs/by-name/nh/nheko_unstable/package.nix"
        "--version"
        "branch=master"
      ];
    };
  };
})
