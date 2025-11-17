{
  flake.unify.modules."services/pipewire" = {
    nixos = {
      meta = {
        requires = [
          "external/preservation"
          "security/rtkit"
        ];
      };

      module =
        { ... }:
        {
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            jack.enable = true;
            pulse.enable = true;
            systemWide = true;
          };

          preservation.directories = [ "/var/lib/pipewire" ];
        };
    };
  };
}
