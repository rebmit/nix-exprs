# Portions of this file are sourced from
# https://github.com/xddxdd/nixos-config/blob/710791365eef89076a742c000ddc3e719dbc8582/helpers/fn/service-harden.nix
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/cloud/services.nix
{ lib, ... }:
lib.mapAttrs (_k: lib.mkOptionDefault) {
  AmbientCapabilities = "";
  CapabilityBoundingSet = "";
  LockPersonality = true;
  MemoryDenyWriteExecute = true;
  NoNewPrivileges = true;
  PrivateDevices = true;
  PrivateMounts = true;
  PrivateTmp = true;
  ProcSubset = "pid";
  ProtectClock = true;
  ProtectControlGroups = true;
  ProtectHome = true;
  ProtectHostname = true;
  ProtectKernelLogs = true;
  ProtectKernelModules = true;
  ProtectKernelTunables = true;
  ProtectProc = "invisible";
  ProtectSystem = "strict";
  RemoveIPC = true;
  RestrictAddressFamilies = [
    "AF_UNIX"
    "AF_INET"
    "AF_INET6"
  ];
  RestrictNamespaces = true;
  RestrictRealtime = true;
  RestrictSUIDSGID = true;
  SystemCallArchitectures = "native";
  SystemCallErrorNumber = "EPERM";
  SystemCallFilter = [
    ""
    "@system-service"
    "~@resources"
    "~@privileged"
  ];
  UMask = "0077";
}
