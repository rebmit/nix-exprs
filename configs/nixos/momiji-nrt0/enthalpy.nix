{
  flake.unify.configs.nixos.momiji-nrt0 = {
    meta = {
      includes = [ "services/enthalpy/common" ];
    };

    module =
      { ... }:
      {
        services.enthalpy = {
          ipsec = {
            interfaces = [ "enp1s0" ];
          };
          srv6.enable = true;
        };
      };
  };
}
