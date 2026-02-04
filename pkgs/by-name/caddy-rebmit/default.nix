let
  caddy-rebmit =
    {
      lib,
      buildGo125Module,
      installShellFiles,
      stdenv,
      writableTmpDirAsHomeHook,
      versionCheckHook,
      source,
    }:

    buildGo125Module (finalAttrs: {
      inherit (source)
        pname
        version
        src
        vendorHash
        ;

      ldflags = [
        "-s"
        "-w"
        "-X github.com/caddyserver/caddy/v2.CustomVersion=${finalAttrs.version}"
      ];

      # matches upstream since v2.8.0
      tags = [
        "nobadger"
        "nomysql"
        "nopgx"
      ];

      nativeBuildInputs = [ installShellFiles ];

      nativeCheckInputs = [ writableTmpDirAsHomeHook ];

      __darwinAllowLocalNetworking = true;

      postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        # Generating man pages and completions fail on cross-compilation
        # https://github.com/NixOS/nixpkgs/issues/308283

        $out/bin/caddy manpage --directory manpages
        installManPage manpages/*

        installShellCompletion --cmd caddy \
          --bash <($out/bin/caddy completion bash) \
          --fish <($out/bin/caddy completion fish) \
          --zsh <($out/bin/caddy completion zsh)
      '';

      nativeInstallCheckInputs = [
        writableTmpDirAsHomeHook
        versionCheckHook
      ];
      versionCheckKeepEnvironment = [ "HOME" ];
      doInstallCheck = true;

      meta = {
        description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
        homepage = "https://caddyserver.com";
        license = lib.licenses.asl20;
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.unix;
        mainProgram = "caddy";
      };
    });
in
{
  overlays.default =
    { final, ... }:
    {
      caddy-rebmit =
        let
          source = {
            pname = "caddy";
            version = "2.10.2-unstable-2026-02-04";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "rebmit";
                repo = "caddy";
                rev = "fcdd848a890c335519a595e9ee9f11ec67995cb2";
                hash = "sha256-dd+pM+NYRq9OfOhvbI2gPjlynF5DQy/jlVqMC3xwD4E=";
              }
            ) { };
            vendorHash = "sha256-61eTMq3Ra/YBS2iBUkcYub2ybxZ8UI6ETVJbrZlMxvg=";
          };
        in
        final.callPackage caddy-rebmit { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) caddy-rebmit;
      };
    };
}
