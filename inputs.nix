(import
  (fetchTree {
    type = "github";
    owner = "rebmit";
    repo = "flake-compat";
    rev = "e424d5283c6d41d1540d01651d7fe62124187248";
    lastModified = 1785052610;
    narHash = "sha256-9Ac+R7dPe830FUwAJgbmUqRjvDm5EYD5rKEsvuWu8sg=";
  })
  {
    src = ./.;
    copySourceTreeToStore = false;
    useBuiltinsFetchTree = true;
  }
).inputs
