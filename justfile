set shell := ["bash", "-c"]

[group('nix')]
up *args:
  #!/usr/bin/env bash
  for dir in . ./dev/_flake ./hosts/_flake; do
    pushd "$dir" > /dev/null
    nix flake update {{args}}
    popd > /dev/null
  done

[group('nix')]
history:
  nix profile diff-closures --profile /nix/var/nix/profiles/system
