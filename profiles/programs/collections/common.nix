{
  flake.unify.modules."programs/collections/common" = {
    nixos = {
      module =
        { pkgs, ... }:
        {
          programs.htop = {
            enable = true;
            settings = {
              show_program_path = 0;
              highlight_base_name = 1;
              hide_userland_threads = true;
            };
          };

          environment.systemPackages = with pkgs; [
            # keep-sorted start
            _7zz
            binutils
            dnsutils
            fd
            file
            jq
            libtree
            openssl
            psmisc
            ripgrep
            rsync
            strace
            tree
            unar
            unzipNLS
            zip
            # keep-sorted end
          ];
        };
    };

    homeManager = {
      module =
        { config, pkgs, ... }:
        {
          home.packages = with pkgs; [
            fastfetch
            numbat
          ];

          home.sessionVariables = {
            HISTFILE = "${config.xdg.stateHome}/bash_history";
            PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
          };
        };
    };
  };
}
