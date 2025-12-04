{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        commands = map (cmd: cmd // { category = "nix"; }) [
          {
            name = "nix-flake-update";
            help = "Update all flake partitions under this project";
            command = ''
              if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
                echo "Error: This command must be run inside a Git repository."
                exit 1
              fi

              dirs=(
                "$PRJ_ROOT"
                "$PRJ_ROOT/dev/_flake"
                "$PRJ_ROOT/configs/_flake"
              )

              for dir in "''${dirs[@]}"; do
                pushd "$dir" > /dev/null
                nix flake update "$@"
                popd > /dev/null
              done
            '';
          }
          {
            package = pkgs.nixos-anywhere;
            help = "Install nixos everywhere via ssh";
          }
        ];
      };
    };
}
