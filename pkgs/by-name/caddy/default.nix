{
  lib,
  buildGo125Module,
  installShellFiles,
  stdenv,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:

{
  pname ? "caddy",
  version,
  src,
  vendorHash,
}:

buildGo125Module (finalAttrs: {
  inherit
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
})
