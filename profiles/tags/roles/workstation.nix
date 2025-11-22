{
  flake.unify.modules."tags/roles/workstation" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "programs/collections/system"
          "services/sshd"
          "services/zram-generator"
          "users/rebmit"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [ ];
      };
    };
  };
}
