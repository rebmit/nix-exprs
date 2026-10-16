{
  nheko,
  lib,
  fetchFromGitHub,
  mtxclient_unstable,
  nix-update-script,
}:

(nheko.override { mtxclient = mtxclient_unstable; }).overrideAttrs (oldAttrs: {
  version = "0.12.1-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "b15dcd137e5384e0aabfd35583b5a6eba5f71ed9";
    hash = "sha256-2mRt9WZ/2/WGBHs4Cj3RaefQ/i7+DqNJBt1NJrLVcXQ=";
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
        "pkgs/by-name/nheko_unstable/package.nix"
        "--version"
        "branch=master"
      ];
    };
  };
})
