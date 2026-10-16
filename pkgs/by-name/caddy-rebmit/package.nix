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
  version = "2.11.7-unstable-2026-10-16";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "caddy";
    rev = "0efbc87c7a9be4f945fbea6094ad02efa5a1fdca";
    hash = "sha256-JDZUa7m7xetxt0DoC+7JNKITV2FFSkFa3TSiC4jD7m0=";
  };

  vendorHash = "sha256-yyLIEx9SLQ0XC8G7uIzSLDJ8Gc5/DJz5ZrnZtydtpi4=";

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
