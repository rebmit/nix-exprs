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
            version = "2.11.2-unstable-2026-03-07";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "rebmit";
                repo = "caddy";
                rev = "041287379b6f771e7b6a6dfcf8871fa4d1cc4b71";
                hash = "sha256-VpVE2XiaE0tVBIbPdAtLYRhYVIYprWFPlRQpluYJyo8=";
              }
            ) { };
            vendorHash = "sha256-7A/fQkUSCqV68thmV/AxOab8UKRr6ro/YLEYwsgiQSw=";
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
