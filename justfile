set shell := ["bash", "-c"]

[group('nix')]
up:
  nix flake update

[group('nix')]
upp input:
  nix flake lock --update-input {{input}}
