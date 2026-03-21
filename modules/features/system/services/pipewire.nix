{
  unify.features.system._.services._.pipewire =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/preservation"
        "features/system/security/rtkit"
        # keep-sorted end
      ];

      nixos =
        { ... }:
        {
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            jack.enable = true;
            pulse.enable = true;
            systemWide = true;
          };

          preservation.preserveAt.state.directories = [ "/var/lib/pipewire" ];
        };
    };
}
