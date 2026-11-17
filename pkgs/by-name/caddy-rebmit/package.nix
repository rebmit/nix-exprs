{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  writableTmpDirAsHomeHook,
  versionCheckHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "caddy";
  version = "2.11.9-unstable-2026-11-17";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "caddy";
    rev = "b34644fc227b8a280b44d0a8b80c6f9739d3612c";
    hash = "sha256-o/sl5oDzenALLhLHLsBalM/n0JVKjGkWlNNjy2klV/M=";
  };

  vendorHash = "sha256-HG4J7x6M6GGVlpVyGe5YbQwBRzYh5P02EcpL1ZfGMzU=";

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

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch=master"
      ];
    };
  };

  meta = {
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    homepage = "https://caddyserver.com";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.unix;
    mainProgram = "caddy";
  };
})
