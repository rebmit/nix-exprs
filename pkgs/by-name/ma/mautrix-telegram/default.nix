{
  scopes.default =
    { final, prev, ... }:
    {
      mautrix-telegram = prev.mautrix-telegram.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [
          (final.fetchpatch2 {
            name = "mautrix-telegram-sticker";
            url = "https://github.com/mautrix/telegram/pull/991/commits/0c2764e3194fb4b029598c575945060019bad236.patch";
            hash = "sha256-48QiKByX/XKDoaLPTbsi4rrlu9GwZM26/GoJ12RA2qE=";
          })
        ];
      });
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) mautrix-telegram;
    };
}
