{
  self,
  lib,
  meta,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.asserts) assertMsg;
  inherit (lib.attrsets)
    foldlAttrs
    filterAttrs
    attrNames
    mapAttrsToList
    listToAttrs
    nameValuePair
    optionalAttrs
    ;
  inherit (lib.lists)
    length
    flatten
    replicate
    reverseList
    take
    ;
  inherit (lib.network.ipv6) fromString;
  inherit (lib.options) mkOption;
  inherit (lib.strings)
    optionalString
    concatMapStringsSep
    concatStringsSep
    fromJSON
    splitString
    concatStrings
    stringLength
    stringToCharacters
    ;
  inherit (lib.trivial) readFile;
  inherit (self.lib.network.ipv6) cidrHost;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  ipv6Normalize =
    ipv6:
    let
      parsed = splitString ":" (fromString ipv6).address;
      pad = hextet: concatStrings (replicate (4 - stringLength hextet) "0") + hextet;
      normalize = hextet: stringToCharacters (pad hextet);
    in
    flatten (map normalize parsed);

  ipv6ToPtr =
    ipv6: prefixLen:
    let
      parsed = reverseList (ipv6Normalize ipv6);
      ptr = concatStringsSep "." (take (32 - prefixLen) parsed);
    in
    ptr;
in
{
  options.meta = mkSubmoduleOptions {
    ports = mkOption {
      type = types.attrsOf types.port;
      default = { };
      apply =
        ports:
        let
          reverse = foldlAttrs (
            acc: name: value:
            acc
            // {
              ${toString value} = (acc.${toString value} or [ ] ++ [ name ]);
            }
          ) { } ports;

          duplicates = filterAttrs (_name: value: length value > 1) reverse;

          collisionMsg =
            optionalString (duplicates != { }) "Port collision detected:\n"
            + concatMapStringsSep "\n" (port: "  ${port}: ${concatStringsSep ", " duplicates.${port}}") (
              attrNames duplicates
            );
        in
        assert assertMsg (duplicates == { }) collisionMsg;
        ports;
      description = ''
        A mapping of network ports, each identified by a unique name.
      '';
    };

    zones = mkOption {
      type = types.attrsOf (
        types.submodule {
          freeformType = mkStructuredType { typeName = "zone"; };
        }
      );
      default = { };
      description = ''
        A set of DNS zones managed by this flake.
      '';
    };
  };

  config = {
    meta.data = fromJSON (readFile ../../infra/data.json);

    meta.ports = {
      # keep-sorted start by_regex=(\d+) numeric=yes
      ssh = 22;
      smtp = 25;
      domain = 53;
      http = 80;
      https = 443;
      submissions = 465;
      imaps = 993;
      ssh-alt = 2222;
      # keep-sorted end
    };

    meta.zones =
      let
        publicHosts = filterAttrs (_: v: v.endpoints != [ ]) meta.data.hosts;
        enthalpyHosts = filterAttrs (_: v: v.enthalpy_node_prefix != null) meta.data.hosts;
      in
      {
        "rebmit.link" = {
          subdomains = listToAttrs (
            mapAttrsToList (
              n: v:
              nameValuePair n {
                A = v.endpoints_v4;
                AAAA = v.endpoints_v6;
                HTTPS = [
                  (
                    {
                      svcPriority = 1;
                      targetName = ".";
                      alpn = [
                        "h3"
                        "h2"
                      ];
                    }
                    // (optionalAttrs (v.endpoints_v4 != [ ])) {
                      ipv4hint = v.endpoints_v4;
                    }
                    // (optionalAttrs (v.endpoints_v6 != [ ])) {
                      ipv6hint = v.endpoints_v6;
                    }
                  )
                ];
              }
            ) publicHosts
            ++ mapAttrsToList (
              n: v:
              nameValuePair "${n}.enta" {
                AAAA = [ (cidrHost 1 v.enthalpy_node_prefix) ];
                HTTPS = [
                  {
                    svcPriority = 1;
                    targetName = ".";
                    alpn = [
                      "h3"
                      "h2"
                    ];
                    ipv6hint = [ (cidrHost 1 v.enthalpy_node_prefix) ];
                  }
                ];
              }
            ) enthalpyHosts
          );
        };
        "1.2.e.7.0.a.a.e.0.a.2.ip6.arpa" = {
          subdomains = listToAttrs (
            mapAttrsToList (
              n: v:
              nameValuePair "${ipv6ToPtr (cidrHost 1 v.enthalpy_node_prefix) 11}" {
                PTR = [ "${n}.enta.rebmit.link" ];
              }
            ) enthalpyHosts
          );
        };
      };
  };
}
