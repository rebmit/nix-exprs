{
  unify.profiles.services._.pipewire =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/security/rtkit"
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
