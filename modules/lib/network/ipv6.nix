{
  inputs,
  lib,
  ...
}:
let
  inherit (lib.lists)
    foldl'
    singleton
    last
    genList
    elemAt
    replicate
    zipListsWith
    takeEnd
    all
    ;
  inherit (lib.trivial)
    id
    bitAnd
    bitOr
    isInt
    ;

  inherit ((import (inputs.nixpkgs + "/lib/network/internal.nix") { inherit lib; })._ipv6)
    split
    toStringFromExpandedIp
    ;

  inherit (builtins) div;
  mod = a: b: a - (div a b) * b;

  lut = foldl' (l: _: l ++ singleton (2 * last l)) [ 1 ] (genList id 62);

  ipv6Bits = 128;
  ipv6Pieces = 8;
  ipv6PieceBits = 16;
  ipv6PieceMaxValue = elemAt lut ipv6PieceBits;

  bitwiseAnd = a: b: zipListsWith (x: y: bitAnd x y) a b;
  bitwiseOr = a: b: zipListsWith (x: y: bitOr x y) a b;
  bitwiseNot = map (x: ipv6PieceMaxValue - 1 - x);

  bitwiseShiftLeft =
    n: a:
    let
      pieceShift = div n ipv6PieceBits;
      bitShift = mod n ipv6PieceBits;

      piecewiseMapShiftLeft =
        n: f: a:
        takeEnd ipv6Pieces ((map f a) ++ replicate n 0);

      quotient = piecewiseMapShiftLeft (pieceShift + 1) (
        x: div (x * (elemAt lut bitShift)) ipv6PieceMaxValue
      ) a;
      remainder = piecewiseMapShiftLeft pieceShift (
        x: mod (x * (elemAt lut bitShift)) ipv6PieceMaxValue
      ) a;
    in
    bitwiseOr quotient remainder;

  toPieces =
    x:
    if isInt x then
      replicate 4 0 ++ genList (i: mod (div x (elemAt lut (ipv6PieceBits * (3 - i)))) ipv6PieceMaxValue) 4
    else
      throw "not supported value type";

  suffixMask =
    n:
    let
      pieces = div n ipv6PieceBits;
      remainingBits = mod n ipv6PieceBits;
    in
    takeEnd ipv6Pieces (
      replicate ipv6Pieces 0
      ++ singleton (elemAt lut remainingBits - 1)
      ++ replicate pieces (ipv6PieceMaxValue - 1)
    );

  prefixMask = n: bitwiseNot (suffixMask (ipv6Bits - n));

  checkMask = a: mask: all (x: x == 0) (bitwiseAnd mask a);
in
{
  flake.lib =
    _:
    let
      cidrHost =
        netnum: cidr:
        let
          splittedAttr = split cidr;
          inherit (splittedAttr) address prefixLength;

          mask = prefixMask prefixLength;
          netnumInternal = toPieces netnum;
        in
        if checkMask netnumInternal mask then
          toStringFromExpandedIp (bitwiseOr address netnumInternal)
        else
          throw "invalid netnum";

      cidrSubnet =
        newbits: netnum: cidr:
        let
          splittedAttr = split cidr;
          inherit (splittedAttr) address prefixLength;

          mask = bitwiseOr (prefixMask prefixLength) (suffixMask (ipv6Bits - prefixLength - newbits));
          netnumInternal = bitwiseShiftLeft (ipv6Bits - prefixLength - newbits) (toPieces netnum);
        in
        if checkMask netnumInternal mask then
          "${toStringFromExpandedIp (bitwiseOr address netnumInternal)}/${toString (prefixLength + newbits)}"
        else
          throw "invalid netnum";
    in
    {
      network.ipv6 = {
        inherit cidrHost cidrSubnet;
      };
    };
}
