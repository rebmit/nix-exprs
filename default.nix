{
  system ? builtins.currentSystem,
}:

let
  target =
    {
      "aarch64-darwin" = "aarch64-darwin";
      "aarch64-linux" = "aarch64-linux-gnu";
      "x86_64-linux" = "x86_64-linux-gnu";
    }
    .${system};

  outputs = import ./outputs.nix { };
in
outputs
// outputs.packages.${target}
// {
  devshells = outputs.devshells.${target};
  formatters = outputs.formatters.${target};
}
