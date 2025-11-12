{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      tags = [
        # keep-sorted start
        "baseline"
        "desktop/niri"
        "immutable"
        "multimedia"
        "workstation"
        # keep-sorted end
      ];
    };

    system = "x86_64-linux";

    submodules.home-manager.users.rebmit = { };

    module = _: {
      system.stateVersion = "25.11";
    };
  };
}
