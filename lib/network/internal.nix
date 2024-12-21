# Portions of this file are sourced from
# https://gist.github.com/duairc/5c9bb3c922e5d501a1edb9e7b3b845ba
{ ... }:
let
  list = {
    cons = a: b: [ a ] ++ b;
  };

  bit = rec {
    shift =
      n: x:
      if n < 0 then
        x * math.pow 2 (-n)
      else
        let
          safeDiv = n: d: if d == 0 then 0 else n / d;
          d = math.pow 2 n;
        in
        if x < 0 then not (safeDiv (not x) d) else safeDiv x d;

    left = n: shift (-n);

    right = shift;

    and = builtins.bitAnd;

    or = builtins.bitOr;

    xor = builtins.bitXor;

    not = xor (-1);

    mask = n: and (left n 1 - 1);
  };

  math = rec {
    max = a: b: if a > b then a else b;

    min = a: b: if a < b then a else b;

    clamp =
      a: b: c:
      max a (min b c);

    pow =
      x: n:
      if n == 0 then
        1
      else if bit.and n 1 != 0 then
        x * pow (x * x) ((n - 1) / 2)
      else
        pow (x * x) (n / 2);
  };

  parsers =
    let
      # fmap :: (a -> b) -> parser a -> parser b
      fmap = f: ma: bind ma (a: pure (f a));

      # pure :: a -> parser a
      pure = a: string: {
        leftovers = string;
        result = a;
      };

      # liftA2 :: (a -> b -> c) -> parser a -> parser b -> parser c
      liftA2 =
        f: ma: mb:
        bind ma (a: bind mb (b: pure (f a b)));
      liftA3 =
        f: a: b:
        ap (liftA2 f a b);
      liftA4 =
        f: a: b: c:
        ap (liftA3 f a b c);
      liftA5 =
        f: a: b: c: d:
        ap (liftA4 f a b c d);
      liftA6 =
        f: a: b: c: d: e:
        ap (liftA5 f a b c d e);

      # ap :: parser (a -> b) -> parser a -> parser b
      ap = liftA2 (a: a);

      # then_ :: parser a -> parser b -> parser b
      then_ = liftA2 (_a: b: b);

      # empty :: parser a
      empty = _string: null;

      # alt :: parser a -> parser a -> parser a
      alt =
        left: right: string:
        let
          result = left string;
        in
        if builtins.isNull result then right string else result;

      # guard :: bool -> parser {}
      guard = condition: if condition then pure { } else empty;

      # mfilter :: (a -> bool) -> parser a -> parser a
      mfilter = f: parser: bind parser (a: then_ (guard (f a)) (pure a));

      # some :: parser a -> parser [a]
      some = v: liftA2 list.cons v (many v);

      # many :: parser a -> parser [a]
      many = v: alt (some v) (pure [ ]);

      # bind :: parser a -> (a -> parser b) -> parser b
      bind =
        parser: f: string:
        let
          a = parser string;
        in
        if builtins.isNull a then null else f a.result a.leftovers;

      # run :: parser a -> string -> maybe a
      run =
        parser: string:
        let
          result = parser string;
        in
        if builtins.isNull result || result.leftovers != "" then null else result.result;

      next =
        string:
        if string == "" then
          null
        else
          {
            leftovers = builtins.substring 1 (-1) string;
            result = builtins.substring 0 1 string;
          };

      # Count how many characters were consumed by a parser
      count =
        parser: string:
        let
          result = parser string;
        in
        if builtins.isNull result then
          null
        else
          result
          // {
            result = {
              inherit (result) result;
              count = with result; builtins.stringLength string - builtins.stringLength leftovers;
            };
          };

      # Limit the parser to n characters at most
      limit = n: parser: fmap (a: a.result) (mfilter (a: a.count <= n) (count parser));

      # Ensure the parser consumes exactly n characters
      exactly = n: parser: fmap (a: a.result) (mfilter (a: a.count == n) (count parser));

      char = c: bind next (c': guard (c == c'));

      string =
        css:
        if css == "" then
          pure { }
        else
          let
            c = builtins.substring 0 1 css;
            cs = builtins.substring 1 (-1) css;
          in
          then_ (char c) (string cs);

      digit = set: bind next (c: then_ (guard (builtins.hasAttr c set)) (pure (builtins.getAttr c set)));

      decimalDigits = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
      };

      hexadecimalDigits = decimalDigits // {
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };

      fromDecimalDigits = builtins.foldl' (a: c: a * 10 + c) 0;
      fromHexadecimalDigits = builtins.foldl' (a: bit.or (bit.left 4 a)) 0;

      # disallow leading zeros
      decimal = bind (digit decimalDigits) (
        n:
        if n == 0 then
          pure 0
        else
          fmap (ns: fromDecimalDigits (list.cons n ns)) (many (digit decimalDigits))
      );

      hexadecimal = fmap fromHexadecimalDigits (some (digit hexadecimalDigits));

      ipv4 =
        let
          dot = char ".";

          octet = mfilter (n: n < 256) decimal;

          octet' = then_ dot octet;

          fromOctets = a: b: c: d: {
            ipv4 = bit.or (bit.left 8 (bit.or (bit.left 8 (bit.or (bit.left 8 a) b)) c)) d;
          };
        in
        liftA4 fromOctets octet octet' octet' octet';

      # This is more or less a literal translation of
      # https://hackage.haskell.org/package/ip/docs/src/Net.IPv6.html#parser
      ipv6 =
        let
          colon = char ":";

          hextet = limit 4 hexadecimal;

          fromHextets =
            hextets:
            if builtins.length hextets != 8 then
              empty
            else
              let
                a = builtins.elemAt hextets 0;
                b = builtins.elemAt hextets 1;
                c = builtins.elemAt hextets 2;
                d = builtins.elemAt hextets 3;
                e = builtins.elemAt hextets 4;
                f = builtins.elemAt hextets 5;
                g = builtins.elemAt hextets 6;
                h = builtins.elemAt hextets 7;
              in
              pure {
                ipv6 = {
                  a = bit.or (bit.left 16 a) b;
                  b = bit.or (bit.left 16 c) d;
                  c = bit.or (bit.left 16 e) f;
                  d = bit.or (bit.left 16 g) h;
                };
              };

          ipv4' = fmap (
            address:
            let
              upper = bit.right 16 address.ipv4;
              lower = bit.mask 16 address.ipv4;
            in
            [
              upper
              lower
            ]
          ) ipv4;

          part =
            n:
            let
              n' = n + 1;
              hex = liftA2 list.cons hextet (then_ colon (alt (then_ colon (doubleColon n')) (part n')));
            in
            if n == 7 then
              fmap (a: [ a ]) hextet
            else if n == 6 then
              alt ipv4' hex
            else
              hex;

          doubleColon =
            n:
            bind (alt afterDoubleColon (pure [ ])) (
              rest:
              let
                missing = 8 - n - builtins.length rest;
              in
              if missing < 0 then empty else pure (builtins.genList (_: 0) missing ++ rest)
            );

          afterDoubleColon = alt ipv4' (
            liftA2 list.cons hextet (alt (then_ colon afterDoubleColon) (pure [ ]))
          );
        in
        bind (alt (then_ (string "::") (doubleColon 0)) (part 0)) fromHextets;

      cidrv4 = liftA2 (base: length: implementations.cidr.make length base) ipv4 (
        then_ (char "/") (mfilter (n: n <= 32) decimal)
      );

      cidrv6 = liftA2 (base: length: implementations.cidr.make length base) ipv6 (
        then_ (char "/") (mfilter (n: n <= 128) decimal)
      );

      mac =
        let
          colon = char ":";

          octet = exactly 2 hexadecimal;

          octet' = then_ colon octet;

          fromOctets = a: b: c: d: e: f: {
            mac = bit.or (bit.left 8 (bit.or (bit.left 8 (bit.or (bit.left 8 (bit.or (bit.left 8 (bit.or (bit.left 8 a) b)) c)) d)) e)) f;
          };
        in
        liftA6 fromOctets octet octet' octet' octet' octet' octet';
    in
    {
      ipv4 = run ipv4;
      ipv6 = run ipv6;
      ip = run (alt ipv4 ipv6);
      cidrv4 = run cidrv4;
      cidrv6 = run cidrv6;
      cidr = run (alt cidrv4 cidrv6);
      mac = run mac;
      numeric = run (alt (alt ipv4 ipv6) mac);
    };

  builders =
    let
      ipv4 =
        address:
        let
          abcd = address.ipv4;
          abc = bit.right 8 abcd;
          ab = bit.right 8 abc;
          a = bit.right 8 ab;
          b = bit.mask 8 ab;
          c = bit.mask 8 abc;
          d = bit.mask 8 abcd;
        in
        builtins.concatStringsSep "." (
          map toString [
            a
            b
            c
            d
          ]
        );

      # This is more or less a literal translation of
      # https://hackage.haskell.org/package/ip/docs/src/Net.IPv6.html#encode
      ipv6 =
        address:
        let
          digits = "0123456789abcdef";

          toHexString =
            n:
            let
              rest = bit.right 4 n;
              current = bit.mask 4 n;
              prefix = if rest == 0 then "" else toHexString rest;
            in
            "${prefix}${builtins.substring current 1 digits}";
        in
        if (with address.ipv6; a == 0 && b == 0 && c == 0 && d > 65535) then
          "::${ipv4 { ipv4 = address.ipv6.d; }}"
        else if (with address.ipv6; a == 0 && b == 0 && c == 65535) then
          "::ffff:${ipv4 { ipv4 = address.ipv6.d; }}"
        else
          let
            a = bit.right 16 address.ipv6.a;
            b = bit.mask 16 address.ipv6.a;
            c = bit.right 16 address.ipv6.b;
            d = bit.mask 16 address.ipv6.b;
            e = bit.right 16 address.ipv6.c;
            f = bit.mask 16 address.ipv6.c;
            g = bit.right 16 address.ipv6.d;
            h = bit.mask 16 address.ipv6.d;

            hextets = [
              a
              b
              c
              d
              e
              f
              g
              h
            ];

            # calculate the position and size of the longest sequence of
            # zeroes within the list of hextets
            longest =
              let
                go =
                  i: current: best:
                  if i < builtins.length hextets then
                    let
                      n = builtins.elemAt hextets i;

                      current' =
                        if n == 0 then
                          if builtins.isNull current then
                            {
                              size = 1;
                              position = i;
                            }
                          else
                            current
                            // {
                              size = current.size + 1;
                            }
                        else
                          null;

                      best' =
                        if n == 0 then
                          if builtins.isNull best then
                            current'
                          else if current'.size > best.size then
                            current'
                          else
                            best
                        else
                          best;
                    in
                    go (i + 1) current' best'
                  else
                    best;
              in
              go 0 null null;

            format = hextets: builtins.concatStringsSep ":" (map toHexString hextets);
          in
          if builtins.isNull longest then
            format hextets
          else
            let
              sublist =
                i: length: xs:
                map (builtins.elemAt xs) (builtins.genList (x: x + i) length);

              end = longest.position + longest.size;

              before = sublist 0 longest.position hextets;

              after = sublist end (builtins.length hextets - end) hextets;
            in
            "${format before}::${format after}";

      ip = address: if address ? ipv4 then ipv4 address else ipv6 address;

      cidrv4 = cidr: "${ipv4 cidr.base}/${toString cidr.length}";

      cidrv6 = cidr: "${ipv6 cidr.base}/${toString cidr.length}";

      cidr = cidr: "${ip cidr.base}/${toString cidr.length}";

      mac =
        address:
        let
          digits = "0123456789abcdef";
          octet =
            n:
            let
              upper = bit.right 4 n;
              lower = bit.mask 4 n;
            in
            "${builtins.substring upper 1 digits}${builtins.substring lower 1 digits}";
        in
        let
          a = bit.mask 8 (bit.right 40 address.mac);
          b = bit.mask 8 (bit.right 32 address.mac);
          c = bit.mask 8 (bit.right 24 address.mac);
          d = bit.mask 8 (bit.right 16 address.mac);
          e = bit.mask 8 (bit.right 8 address.mac);
          f = bit.mask 8 (bit.right 0 address.mac);
        in
        "${octet a}:${octet b}:${octet c}:${octet d}:${octet e}:${octet f}";
    in
    {
      inherit
        ipv4
        ipv6
        ip
        cidrv4
        cidrv6
        cidr
        mac
        ;
    };

  arithmetic = rec {
    # or :: (ip | mac | integer) -> (ip | mac | integer) -> (ip | mac | integer)
    or =
      a_: b:
      let
        a = coerce b a_;
      in
      if a ? ipv6 then
        {
          ipv6 = {
            a = bit.or a.ipv6.a b.ipv6.a;
            b = bit.or a.ipv6.b b.ipv6.b;
            c = bit.or a.ipv6.c b.ipv6.c;
            d = bit.or a.ipv6.d b.ipv6.d;
          };
        }
      else if a ? ipv4 then
        {
          ipv4 = bit.or a.ipv4 b.ipv4;
        }
      else if a ? mac then
        {
          mac = bit.or a.mac b.mac;
        }
      else
        bit.or a b;

    # and :: (ip | mac | integer) -> (ip | mac | integer) -> (ip | mac | integer)
    and =
      a_: b:
      let
        a = coerce b a_;
      in
      if a ? ipv6 then
        {
          ipv6 = {
            a = bit.and a.ipv6.a b.ipv6.a;
            b = bit.and a.ipv6.b b.ipv6.b;
            c = bit.and a.ipv6.c b.ipv6.c;
            d = bit.and a.ipv6.d b.ipv6.d;
          };
        }
      else if a ? ipv4 then
        {
          ipv4 = bit.and a.ipv4 b.ipv4;
        }
      else if a ? mac then
        {
          mac = bit.and a.mac b.mac;
        }
      else
        bit.and a b;

    # not :: (ip | mac | integer) -> (ip | mac | integer)
    not =
      a:
      if a ? ipv6 then
        {
          ipv6 = {
            a = bit.mask 32 (bit.not a.ipv6.a);
            b = bit.mask 32 (bit.not a.ipv6.b);
            c = bit.mask 32 (bit.not a.ipv6.c);
            d = bit.mask 32 (bit.not a.ipv6.d);
          };
        }
      else if a ? ipv4 then
        {
          ipv4 = bit.mask 32 (bit.not a.ipv4);
        }
      else if a ? mac then
        {
          mac = bit.mask 48 (bit.not a.mac);
        }
      else
        bit.not a;

    # add :: (ip | mac | integer) -> (ip | mac | integer) -> (ip | mac | integer)
    add =
      let
        split = a: {
          fst = bit.mask 32 (bit.right 32 a);
          snd = bit.mask 32 a;
        };
      in
      a_: b:
      let
        a = coerce b a_;
      in
      if a ? ipv6 then
        let
          a' = split (a.ipv6.a + b.ipv6.a + b'.fst);
          b' = split (a.ipv6.b + b.ipv6.b + c'.fst);
          c' = split (a.ipv6.c + b.ipv6.c + d'.fst);
          d' = split (a.ipv6.d + b.ipv6.d);
        in
        {
          ipv6 = {
            a = a'.snd;
            b = b'.snd;
            c = c'.snd;
            d = d'.snd;
          };
        }
      else if a ? ipv4 then
        {
          ipv4 = bit.mask 32 (a.ipv4 + b.ipv4);
        }
      else if a ? mac then
        {
          mac = bit.mask 48 (a.mac + b.mac);
        }
      else
        a + b;

    # subtract :: (ip | mac | integer) -> (ip | mac | integer) -> (ip | mac | integer)
    subtract = a: b: add (add 1 (not (coerce b a))) b;

    # diff :: (ip | mac | integer) -> (ip | mac | integer) -> (ipv6 | integer)
    diff =
      a: b:
      let
        toIPv6 = coerce ({ ipv6.a = 0; });
        result = (subtract b (toIPv6 a)).ipv6;
        max32 = bit.left 32 1 - 1;
      in
      if
        result.a == 0 && result.b == 0 && bit.right 31 result.c == 0
        || result.a == max32 && result.b == max32 && bit.right 31 result.c == 1
      then
        bit.or (bit.left 32 result.c) result.d
      else
        {
          ipv6 = result;
        };

    # left :: integer -> (ip | mac | integer) -> (ip | mac | integer)
    left = i: right (-i);

    # right :: integer -> (ip | mac | integer) -> (ip | mac | integer)
    right =
      let
        step = i: x: {
          _1 = bit.mask 32 (bit.right (i + 96) x);
          _2 = bit.mask 32 (bit.right (i + 64) x);
          _3 = bit.mask 32 (bit.right (i + 32) x);
          _4 = bit.mask 32 (bit.right i x);
          _5 = bit.mask 32 (bit.right (i - 32) x);
          _6 = bit.mask 32 (bit.right (i - 64) x);
          _7 = bit.mask 32 (bit.right (i - 96) x);
        };
        ors = builtins.foldl' bit.or 0;
      in
      i: x:
      if x ? ipv6 then
        let
          a' = step i x.ipv6.a;
          b' = step i x.ipv6.b;
          c' = step i x.ipv6.c;
          d' = step i x.ipv6.d;
        in
        {
          ipv6 = {
            a = ors [
              a'._4
              b'._3
              c'._2
              d'._1
            ];
            b = ors [
              a'._5
              b'._4
              c'._3
              d'._2
            ];
            c = ors [
              a'._6
              b'._5
              c'._4
              d'._3
            ];
            d = ors [
              a'._7
              b'._6
              c'._5
              d'._4
            ];
          };
        }
      else if x ? ipv4 then
        {
          ipv4 = bit.mask 32 (bit.right i x.ipv4);
        }
      else if x ? mac then
        {
          mac = bit.mask 48 (bit.right i x.mac);
        }
      else
        bit.right i x;

    # shadow :: integer -> (ip | mac | integer) -> (ip | mac | integer)
    shadow = n: a: and (right n (left n (coerce a (-1)))) a;

    # coshadow :: integer -> (ip | mac | integer) -> (ip | mac | integer)
    coshadow = n: a: and (not (right n (left n (coerce a (-1))))) a;

    # coerce :: (ip | mac | integer) -> (ip | mac | integer) -> (ip | mac | integer)
    coerce =
      target: value:
      if target ? ipv6 then
        if value ? ipv6 then
          value
        else if value ? ipv4 then
          {
            ipv6 = {
              a = 0;
              b = 0;
              c = 0;
              d = value.ipv4;
            };
          }
        else if value ? mac then
          {
            ipv6 = {
              a = 0;
              b = 0;
              c = bit.right 32 value.mac;
              d = bit.mask 32 value.mac;
            };
          }
        else
          {
            ipv6 = {
              a = bit.mask 32 (bit.right 96 value);
              b = bit.mask 32 (bit.right 64 value);
              c = bit.mask 32 (bit.right 32 value);
              d = bit.mask 32 value;
            };
          }
      else if target ? ipv4 then
        if value ? ipv6 then
          {
            ipv4 = value.ipv6.d;
          }
        else if value ? ipv4 then
          value
        else if value ? mac then
          {
            ipv4 = bit.mask 32 value.mac;
          }
        else
          {
            ipv4 = bit.mask 32 value;
          }
      else if target ? mac then
        if value ? ipv6 then
          {
            mac = bit.or (bit.left 32 (bit.mask 16 value.ipv6.c)) value.ipv6.d;
          }
        else if value ? ipv4 then
          {
            mac = value.ipv4;
          }
        else if value ? mac then
          value
        else
          {
            mac = bit.mask 48 value;
          }
      else if value ? ipv6 then
        builtins.foldl' bit.or 0 [
          (bit.left 96 value.ipv6.a)
          (bit.left 64 value.ipv6.b)
          (bit.left 32 value.ipv6.c)
          value.ipv6.d
        ]
      else if value ? ipv4 then
        value.ipv4
      else if value ? mac then
        value.mac
      else
        value;
  };

  implementations = {
    ip = {
      # add :: (ip | mac | integer) -> ip -> ip
      add = arithmetic.add;

      # diff :: ip -> ip -> (ipv6 | integer)
      diff = arithmetic.diff;

      # subtract :: (ip | mac | integer) -> ip -> ip
      subtract = arithmetic.subtract;
    };

    mac = {
      # add :: (ip | mac | integer) -> mac -> mac
      add = arithmetic.add;

      # diff :: mac -> mac -> (ipv6 | integer)
      diff = arithmetic.diff;

      # subtract :: (ip | mac | integer) -> mac -> mac
      subtract = arithmetic.subtract;
    };

    cidr = rec {
      # add :: (ip | mac | integer) -> cidr -> cidr
      add =
        delta: cidr:
        let
          size' = size cidr;
        in
        {
          base = arithmetic.left size' (arithmetic.add delta (arithmetic.right size' cidr.base));
          inherit (cidr) length;
        };

      # capacity :: cidr -> integer
      capacity =
        cidr:
        let
          size' = size cidr;
        in
        if size' > 62 then
          9223372036854775807 # maxBound to prevent overflow
        else
          bit.left size' 1;

      # child :: cidr -> cidr -> bool
      child = subcidr: cidr: length subcidr > length cidr && contains (host 0 subcidr) cidr;

      # contains :: ip -> cidr -> bool
      contains = ip: cidr: host 0 (make cidr.length ip) == host 0 cidr;

      # host :: (ip | mac | integer) -> cidr -> ip
      host =
        index: cidr:
        let
          index' = arithmetic.coerce cidr.base index;
        in
        arithmetic.or (arithmetic.shadow cidr.length index') cidr.base;

      # length :: cidr -> integer
      length = cidr: cidr.length;

      # netmask :: cidr -> ip
      netmask = cidr: arithmetic.coshadow cidr.length (arithmetic.coerce cidr.base (-1));

      # size :: cidr -> integer
      size = cidr: (if cidr.base ? ipv6 then 128 else 32) - cidr.length;

      # subnet :: integer -> (ip | mac | integer) -> cidr -> cidr
      subnet =
        length: index: cidr:
        let
          length' = cidr.length + length;
          index' = arithmetic.coerce cidr.base index;
          size = (if cidr.base ? ipv6 then 128 else 32) - length';
        in
        make length' (host (arithmetic.left size index') cidr);

      # make :: integer -> ip -> cidr
      make =
        length: base:
        let
          length' = math.clamp 0 (if base ? ipv6 then 128 else 32) length;
        in
        {
          base = arithmetic.coshadow length' base;
          length = length';
        };
    };
  };

  typechecks =
    let
      fail =
        description: function: argument:
        builtins.throw "${function}: ${argument} parameter must be ${description}";

      meta =
        parser: description: function: argument: input:
        let
          error = fail description function argument;
        in
        if !builtins.isString input then
          error
        else
          let
            result = parser input;
          in
          if builtins.isNull result then error else result;
    in
    {
      int =
        function: argument: input:
        if builtins.isInt input then input else fail "an integer" function argument;
      ip = meta parsers.ip "an IPv4 or IPv6 address";
      cidr = meta parsers.cidr "an IPv4 or IPv6 address range in CIDR notation";
      mac = meta parsers.mac "a MAC address";
      numeric =
        function: argument: input:
        if builtins.isInt input then
          input
        else
          meta parsers.numeric "an integer or IPv4, IPv6 or MAC address" function argument input;
    };
in
{
  inherit typechecks builders implementations;
}
