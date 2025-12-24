{ meta, ... }:
{
  flake.unify.modules."services/enthalpy/common" = {
    nixos = {
      meta = {
        requires = [ "imports/self/default" ];
      };

      module =
        { config, unify, ... }:
        {
          services.enthalpy = {
            enable = true;
            network = "2a0e:aa07:e21c::/47";
            prefix = meta.data.hosts.${unify.name}.enthalpy_node_prefix;

            ipsec = {
              organization = meta.data.hosts.${unify.name}.enthalpy_node_organization;
              endpoints = [
                {
                  serialNumber = "0";
                  addressFamily = "ip4";
                }
                {
                  serialNumber = "1";
                  addressFamily = "ip6";
                }
              ];
              privateKeyPath = config.sops.secrets."enthalpy/private-key".path;
            };
          };

          netns.enthalpy.domain = "enta.rebmit.link";

          sops.secrets."enthalpy/private-key" = {
            opentofu = {
              enable = true;
              useHostOutput = true;
              jqPath = "enthalpy_node_private_key_pem";
            };
            restartUnits = [ "ranet.service" ];
          };

          preservation.preserveAt.state.directories = [ "/var/lib/ranet" ];
        };
    };
  };
}
