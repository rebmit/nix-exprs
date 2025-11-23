{ self, lib, ... }:
let
  inherit (lib.lists) singleton;
in
{
  flake.meta.ports = {
    http = 80;
    https = 443;
  };

  flake.unify.modules."services/envoy/listeners/https" = {
    nixos = {
      meta = {
        requires = [ "services/envoy/common" ];
      };

      module =
        { ... }:
        {
          services.envoy.listeners.https = {
            "@type" = "type.googleapis.com/envoy.config.listener.v3.Listener";
            address.socket_address = {
              address = "::";
              port_value = self.meta.ports.https;
              ipv4_compat = true;
            };
          };

          services.envoy.listeners.http = {
            "@type" = "type.googleapis.com/envoy.config.listener.v3.Listener";
            address.socket_address = {
              address = "::";
              port_value = self.meta.ports.http;
              ipv4_compat = true;
            };
            filter_chains = singleton {
              filters = singleton {
                name = "envoy.filters.network.http_connection_manager";
                typed_config = {
                  "@type" =
                    "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager";
                  stat_prefix = "http_redirect";
                  route_config = {
                    name = "http_redirect_routes";
                    virtual_hosts = singleton {
                      name = "all_hosts";
                      domains = [ "*" ];
                      routes = singleton {
                        match.prefix = "/";
                        redirect.https_redirect = true;
                      };
                    };
                  };
                  http_filters = singleton {
                    name = "envoy.filters.http.router";
                    typed_config = {
                      "@type" = "type.googleapis.com/envoy.extensions.filters.http.router.v3.Router";
                    };
                  };
                };
              };
            };
          };
        };
    };
  };
}
