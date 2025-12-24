{
  flake.unify.modules."services/pipewire" = {
    nixos = {
      meta = {
        requires = [
          "imports/self/preservation"
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

          preservation.preserveAt.state.directories = [ "/var/lib/pipewire" ];
        };
    };
  };
}
