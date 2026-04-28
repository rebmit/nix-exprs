{ lib, ... }:

let
  versionSuffixFromRevision =
    revision: if revision != null then ".${lib.substring 0 12 revision}" else "pre-git";

  revision = revisionFromPath ../.;

  revisionFromPath =
    path:
    let
      gitRepo = path + "/.git";
    in
    path.revision or path.rev
      or (if lib.pathIsGitRepo gitRepo then lib.commitIdFromGitRepo gitRepo else null);
in
{
  inherit
    versionSuffixFromRevision
    revision
    revisionFromPath
    ;
}
