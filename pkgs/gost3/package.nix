{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gost";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "go-gost";
    repo = "gost";
    rev = "v${version}";
    sha256 = "sha256-ep3ZjD+eVKl3PuooDuYeur8xDAcyy6ww2I7f3cYG03o=";
  };

  vendorHash = "sha256-lzyr6Q8yXsuer6dRUlwHEeBewjwGxDslueuvIiZUW70=";

  meta = with lib; {
    description = "GO Simple Tunnel - a simple tunnel written in golang";
    homepage = "https://github.com/go-gost/gost";
    license = licenses.mit;
  };
}
