(import
  (fetchTarball {
    url = "https://github.com/rebmit/flake-compat/archive/e424d5283c6d41d1540d01651d7fe62124187248.tar.gz";
    sha256 = "sha256-9Ac+R7dPe830FUwAJgbmUqRjvDm5EYD5rKEsvuWu8sg=";
  })
  {
    src = ./.;
    copySourceTreeToStore = false;
    useBuiltinsFetchTree = true;
  }
).inputs
