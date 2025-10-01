{
  flake.lib = self: {
    inherit (self.attrsets) flattenTree;
  };
}
