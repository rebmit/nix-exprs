{
  flake.unify.modules."services/pipewire" = {
    nixos = {
      meta = {
        tags = [ "multimedia" ];
        requires = [
          "external/preservation"
          "security/rtkit"
        ];
      };

      module = _: {
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
