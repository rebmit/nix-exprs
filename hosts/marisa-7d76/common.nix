{
  flake.unify.hosts.nixos.marisa-7d76 = {
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

    module = _: {
      system.stateVersion = "25.11";
    };
  };
}
