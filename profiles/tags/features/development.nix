{
  flake.unify.modules."tags/features/development" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "programs/git"
          "programs/ssh"
          "services/nixseparatedebuginfod2"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/xdg/user-dirs"
          "programs/direnv"
          "programs/gdb"
          "programs/git"
          "programs/ssh"
          "services/user/ssh-agent"
          # keep-sorted end
        ];
      };
    };
  };
}
