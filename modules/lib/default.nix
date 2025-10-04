{
  flake.lib = self: {
    inherit (self.attrsets) flattenTree;
    inherit (self.network.ipv6) cidrSubnet cidrHost;
    inherit (self.path)
      concatTwoPaths
      concatPaths
      parentDirectory
      ;
  };
}
