# Portions of this file are sourced from
# https://gist.github.com/duairc/5c9bb3c922e5d501a1edb9e7b3b845ba
{ lib, ... }:
let
  inherit (import ./internal.nix { inherit lib; }) typechecks builders implementations;
in
{
  ip = {
    # add :: (ip | mac | integer) -> ip -> ip
    #
    # Examples:
    #
    # Adding integer to IPv4:
    # > net.ip.add 100 "10.0.0.1"
    # "10.0.0.101"
    #
    # Adding IPv4 to IPv4:
    # > net.ip.add "127.0.0.1" "10.0.0.1"
    # "137.0.0.2"
    #
    # Adding IPv6 to IPv4:
    # > net.ip.add "::cafe:beef" "10.0.0.1"
    # "212.254.186.191"
    #
    # Adding MAC to IPv4 (overflows):
    # > net.ip.add "fe:ed:fa:ce:f0:0d" "10.0.0.1"
    # "4.206.240.14"
    #
    # Adding integer to IPv6:
    # > net.ip.add 100 "dead:cafe:beef::"
    # "dead:cafe:beef::64"
    #
    # Adding IPv4 to to IPv6:
    # > net.ip.add "127.0.0.1" "dead:cafe:beef::"
    # "dead:cafe:beef::7f00:1"
    #
    # Adding MAC to IPv6:
    # > net.ip.add "fe:ed:fa:ce:f0:0d" "dead:cafe:beef::"
    # "dead:cafe:beef::feed:face:f00d"
    add =
      delta: ip:
      let
        function = "net.ip.add";
        delta' = typechecks.numeric function "delta" delta;
        ip' = typechecks.ip function "ip" ip;
      in
      builders.ip (implementations.ip.add delta' ip');

    # diff :: ip -> ip -> (integer | ipv6)
    #
    # net.ip.diff is the reverse of net.ip.add:
    #
    # net.ip.diff (net.ip.add a b) a = b
    # net.ip.diff (net.ip.add a b) b = a
    #
    # The difference between net.ip.diff and net.ip.subtract is that
    # net.ip.diff will try its best to return an integer (falling back
    # to an IPv6 if the result is too big to fit in an integer). This is
    # useful if you have two hosts that you know are on the same network
    # and you just want to calculate the offset between them — a result
    # like "0.0.0.10" is not very useful (which is what you would get
    # from net.ip.subtract).
    diff =
      minuend: subtrahend:
      let
        function = "net.ip.diff";
        minuend' = typechecks.ip function "minuend" minuend;
        subtrahend' = typechecks.ip function "subtrahend" subtrahend;
        result = implementations.ip.diff minuend' subtrahend';
      in
      if result ? ipv6 then builders.ipv6 result else result;

    # subtract :: (ip | mac | integer) -> ip -> ip
    #
    # net.ip.subtract is also the reverse of net.ip.add:
    #
    # net.ip.subtract a (net.ip.add a b) = b
    # net.ip.subtract b (net.ip.add a b) = a
    #
    # The difference between net.ip.subtract and net.ip.diff is that
    # net.ip.subtract will always return the same type as its "ip"
    # parameter. Its implementation takes the "delta" parameter,
    # coerces it to be the same type as the "ip" paramter, negates it
    # (using two's complement), and then adds it to "ip".
    subtract =
      delta: ip:
      let
        function = "net.ip.subtract";
        delta' = typechecks.numeric function "delta" delta;
        ip' = typechecks.ip function "ip" ip;
      in
      builders.ip (implementations.ip.subtract delta' ip');
  };

  mac = {
    # add :: (ip | mac | integer) -> mac -> mac
    #
    # Examples:
    #
    # Adding integer to MAC:
    # > net.mac.add 100 "fe:ed:fa:ce:f0:0d"
    # "fe:ed:fa:ce:f0:71"
    #
    # Adding IPv4 to MAC:
    # > net.mac.add "127.0.0.1" "fe:ed:fa:ce:f0:0d"
    # "fe:ee:79:ce:f0:0e"
    #
    # Adding IPv6 to MAC:
    # > net.mac.add "::cafe:beef" "fe:ed:fa:ce:f0:0d"
    # "fe:ee:c5:cd:aa:cb
    #
    # Adding MAC to MAC:
    # > net.mac.add "fe:ed:fa:00:00:00" "00:00:00:ce:f0:0d"
    # "fe:ed:fa:ce:f0:0d"
    add =
      delta: mac:
      let
        function = "net.mac.add";
        delta' = typechecks.numeric function "delta" delta;
        mac' = typechecks.mac function "mac" mac;
      in
      builders.mac (implementations.mac.add delta' mac');

    # diff :: mac -> mac -> integer
    #
    # net.mac.diff is the reverse of net.mac.add:
    #
    # net.mac.diff (net.mac.add a b) a = b
    # net.mac.diff (net.mac.add a b) b = a
    #
    # The difference between net.mac.diff and net.mac.subtract is that
    # net.mac.diff will always return an integer.
    diff =
      minuend: subtrahend:
      let
        function = "net.mac.diff";
        minuend' = typechecks.mac function "minuend" minuend;
        subtrahend' = typechecks.mac function "subtrahend" subtrahend;
      in
      implementations.mac.diff minuend' subtrahend';

    # subtract :: (ip | mac | integer) -> mac -> mac
    #
    # net.mac.subtract is also the reverse of net.ip.add:
    #
    # net.mac.subtract a (net.mac.add a b) = b
    # net.mac.subtract b (net.mac.add a b) = a
    #
    # The difference between net.mac.subtract and net.mac.diff is that
    # net.mac.subtract will always return a MAC address.
    subtract =
      delta: mac:
      let
        function = "net.mac.subtract";
        delta' = typechecks.numeric function "delta" delta;
        mac' = typechecks.mac function "mac" mac;
      in
      builders.mac (implementations.mac.subtract delta' mac');
  };

  cidr = {
    # add :: (ip | mac | integer) -> cidr -> cidr
    #
    # > net.cidr.add 2 "127.0.0.0/8"
    # "129.0.0.0/8"
    #
    # > net.cidr.add (-2) "127.0.0.0/8"
    # "125.0.0.0/8"
    add =
      delta: cidr:
      let
        function = "net.cidr.add";
        delta' = typechecks.numeric function "delta" delta;
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      builders.cidr (implementations.cidr.add delta' cidr');

    # child :: cidr -> cidr -> bool
    #
    # > net.cidr.child "10.10.10.0/24" "10.0.0.0/8"
    # true
    #
    # > net.cidr.child "127.0.0.0/8" "10.0.0.0/8"
    # false
    child =
      subcidr: cidr:
      let
        function = "net.cidr.child";
        subcidr' = typechecks.cidr function "subcidr" subcidr;
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      implementations.cidr.child subcidr' cidr';

    # contains :: ip -> cidr -> bool
    #
    # > net.cidr.contains "127.0.0.1" "127.0.0.0/8"
    # true
    #
    # > net.cidr.contains "127.0.0.1" "192.168.0.0/16"
    # false
    contains =
      ip: cidr:
      let
        function = "net.cidr.contains";
        ip' = typechecks.ip function "ip" ip;
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      implementations.cidr.contains ip' cidr';

    # capacity :: cidr -> integer
    #
    # > net.cidr.capacity "172.16.0.0/12"
    # 1048576
    #
    # > net.cidr.capacity "dead:cafe:beef::/96"
    # 4294967296
    #
    # > net.cidr.capacity "dead:cafe:beef::/48" (saturates to maxBound)
    # 9223372036854775807
    capacity =
      cidr:
      let
        function = "net.cidr.capacity";
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      implementations.cidr.capacity cidr';

    # host :: (ip | mac | integer) -> cidr -> ip
    #
    # > net.cidr.host 10000 "10.0.0.0/8"
    # 10.0.39.16
    #
    # > net.cidr.host 10000 "dead:cafe:beef::/64"
    # "dead:cafe:beef::2710"
    #
    # net.cidr.host "127.0.0.1" "dead:cafe:beef::/48"
    # > "dead:cafe:beef::7f00:1"
    #
    # Inpsired by:
    # https://www.terraform.io/docs/configuration/functions/cidrhost.html
    host =
      hostnum: cidr:
      let
        function = "net.cidr.host";
        hostnum' = typechecks.numeric function "hostnum" hostnum;
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      builders.ip (implementations.cidr.host hostnum' cidr');

    # length :: cidr -> integer
    #
    # > net.cidr.length "127.0.0.0/8"
    # 8
    #
    # > net.cidr.length "dead:cafe:beef::/48"
    # 48
    length =
      cidr:
      let
        function = "net.cidr.length";
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      implementations.cidr.length cidr';

    # make :: integer -> ip -> cidr
    #
    # > net.cidr.make 24 "192.168.0.150"
    # "192.168.0.0/24"
    #
    # > net.cidr.make 40 "dead:cafe:beef::feed:face:f00d"
    # "dead:cafe:be00::/40"
    make =
      length: base:
      let
        function = "net.cidr.make";
        length' = typechecks.int function "length" length;
        base' = typechecks.ip function "base" base;
      in
      builders.cidr (implementations.cidr.make length' base');

    # netmask :: cidr -> ip
    #
    # > net.cidr.netmask "192.168.0.0/24"
    # "255.255.255.0"
    #
    # > net.cidr.netmask "dead:cafe:beef::/64"
    # "ffff:ffff:ffff:ffff::"
    netmask =
      cidr:
      let
        function = "net.cidr.netmask";
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      builders.ip (implementations.cidr.netmask cidr');

    # size :: cidr -> integer
    #
    # > net.cidr.size "127.0.0.0/8"
    # 24
    #
    # > net.cidr.size "dead:cafe:beef::/48"
    # 80
    size =
      cidr:
      let
        function = "net.cidr.size";
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      implementations.cidr.size cidr';

    # subnet :: integer -> (ip | mac | integer) -> cidr -> cidr
    #
    # > net.cidr.subnet 4 2 "172.16.0.0/12"
    # "172.18.0.0/16"
    #
    # > net.cidr.subnet 4 15 "10.1.2.0/24"
    # "10.1.2.240/28"
    #
    # > net.cidr.subnet 16 162 "fd00:fd12:3456:7890::/56"
    # "fd00:fd12:3456:7800:a200::/72"
    #
    # Inspired by:
    # https://www.terraform.io/docs/configuration/functions/cidrsubnet.html
    subnet =
      length: netnum: cidr:
      let
        function = "net.cidr.subnet";
        length' = typechecks.int function "length" length;
        netnum' = typechecks.numeric function "netnum" netnum;
        cidr' = typechecks.cidr function "cidr" cidr;
      in
      builders.cidr (implementations.cidr.subnet length' netnum' cidr');
  };
}
