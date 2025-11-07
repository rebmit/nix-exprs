{
  perSystem =
    { prev, ... }:
    let
      ranet =
        {
          lib,
          rustPlatform,
          fetchFromGitHub,
        }:

        rustPlatform.buildRustPackage {
          pname = "ranet";
          version = "0.12.0-unstable-2025-10-08";

          src = fetchFromGitHub {
            owner = "rebmit";
            repo = "ranet";
            rev = "68142d2da05fbb1510a1445f09c0a9f6f9f62d38";
            sha256 = "sha256-b2LMR6WiV87+TW4wPZVgTQzhHBEdxte4HGt/v5LVbzo=";
          };

          cargoHash = "sha256-Qd7Hy/Mq2XihTB7RHQYjRKjaM5eigLxL+MpVyUmBozk=";

          checkFlags = [
            "--skip=address::test::remote"
          ];

          meta = {
            description = "Redundant array of networks";
            homepage = "https://github.com/NickCao/ranet";
            license = lib.licenses.mit;
            maintainers = with lib.maintainers; [ rebmit ];
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      packages.ranet = prev.callPackage ranet { };
    };
}
