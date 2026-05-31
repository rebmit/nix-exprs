final: prev:

let
  callOverlay = path: import path final prev;
in
{
  inherit (callOverlay ../by-name/bird)
    bird2-rebmit
    bird3-rebmit
    ;

  inherit (callOverlay ../by-name/caddy)
    caddy-rebmit
    ;

  inherit (callOverlay ../by-name/mtxclient)
    mtxclient_unstable
    ;

  inherit (callOverlay ../by-name/nheko)
    nheko_unstable
    ;

  inherit (callOverlay ../by-name/ranet)
    ranet
    ;
}
