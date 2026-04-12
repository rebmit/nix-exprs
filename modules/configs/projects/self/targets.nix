{
  includes = [ <rebmit/features/project/targets> ];

  configs.project =
    { ... }:
    {
      targets = {
        # keep-sorted start block=yes
        aarch64-darwin = "arm64-apple-darwin";
        aarch64-linux-gnu = "aarch64-unknown-linux-gnu";
        aarch64-linux-musl = "aarch64-unknown-linux-musl";
        x86_64-linux-gnu = "x86_64-unknown-linux-gnu";
        x86_64-linux-musl = "x86_64-unknown-linux-musl";
        # keep-sorted end
      };
    };
}
