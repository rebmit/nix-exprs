{ lib, ... }:
let
  inherit (lib.attrsets) attrsToList;
  inherit (lib.lists) singleton;
in
{
  unify.profiles.home._.programs._.firefox =
    { user, ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/preservation"
        "profiles/home/misc/username"
        # keep-sorted end
      ];

      contexts.user = { };

      homeManager =
        { pkgs, ... }:
        {
          programs.firefox.enable = true;

          programs.firefox.policies = {
            # keep-sorted start block=yes
            AutofillAddressEnabled = false;
            AutofillCreditCardEnabled = false;
            CaptivePortal = false;
            DisableAppUpdate = true;
            DisableFeedbackCommands = true;
            DisableFirefoxAccounts = true;
            DisableFirefoxStudies = true;
            DisableFormHistory = true;
            DisableMasterPasswordCreation = true;
            DisablePasswordReveal = true;
            DisablePocket = true;
            DisableSetDesktopBackground = true;
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            EnableTrackingProtection = {
              # keep-sorted start block=yes
              BaselineExceptions = true;
              Category = "strict";
              ConvenienceExceptions = true;
              Cryptomining = true;
              EmailTracking = true;
              Fingerprinting = true;
              Locked = true;
              SuspectedFingerprinting = true;
              Value = true;
              # keep-sorted end
            };
            ExtensionSettings = {
              # keep-sorted start block=yes
              "addon@darkreader.org" = {
                installation_mode = "force_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              };
              "firefox@tampermonkey.net" = {
                installation_mode = "force_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/tampermonkey/latest.xpi";
              };
              "uBlock0@raymondhill.net" = {
                installation_mode = "force_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              };
              "zotero@chnm.gmu.edu" = {
                installation_mode = "force_installed";
                install_url = "https://www.zotero.org/download/connector/dl?browser=firefox";
              };
              "{3c078156-979c-498b-8990-85f7987dd929}" = {
                installation_mode = "force_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
              };
              "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
                installation_mode = "force_installed";
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
              };
              # keep-sorted end
            };
            FirefoxHome = {
              # keep-sorted start
              Highlights = false;
              Locked = true;
              Pocket = false;
              Search = true;
              Snippets = false;
              SponsoredPocket = false;
              SponsoredStories = false;
              SponsoredTopSites = false;
              Stories = false;
              TopSites = false;
              # keep-sorted end
            };
            FirefoxSuggest = {
              # keep-sorted start
              ImproveSuggest = false;
              Locked = true;
              SponsoredSuggestions = false;
              WebSuggestions = false;
              # keep-sorted end
            };
            GenerativeAI = {
              # keep-sorted start
              Chatbot = true;
              Enabled = true;
              LinkPreviews = false;
              Locked = true;
              TabGroups = false;
              # keep-sorted end
            };
            HardwareAcceleration = true;
            HttpsOnlyMode = "force_enabled";
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            PasswordManagerEnabled = false;
            PostQuantumKeyAgreementEnabled = true;
            Preferences = {
              # keep-sorted start
              "browser.tabs.inTitlebar" = 1;
              "browser.theme.dark-private-windows" = false;
              "browser.urlbar.suggest.history" = false;
              "browser.urlbar.suggest.topsites" = false;
              "svg.context-properties.content.enabled" = true;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "widget.gtk.rounded-bottom-corners.enabled" = true;
              # keep-sorted end
            };
            SanitizeOnShutdown = {
              # keep-sorted start
              Cache = true;
              Cookies = false;
              FormData = true;
              History = false;
              Locked = true;
              Sessions = false;
              SiteSettings = false;
              # keep-sorted end
            };
            SearchSuggestEnabled = false;
            SkipTermsOfUse = true;
            TranslateEnabled = true;
            UserMessaging = {
              # keep-sorted start
              ExtensionRecommendations = false;
              FeatureRecommendations = false;
              FirefoxLabs = false;
              Locked = true;
              MoreFromMozilla = false;
              SkipOnboarding = true;
              UrlbarInterventions = false;
              # keep-sorted end
            };
            # keep-sorted end
          };

          programs.firefox.profiles.default = {
            isDefault = true;
            search = {
              force = true;
              default = "google";
            };
            search.engines = {
              "bing".metaData.hidden = true;
              "ebay".metaData.hidden = true;
              "amazondotcom-us".metaData.hidden = true;
              "wikipedia".metaData.hidden = true;
              "perplexity".metaData.hidden = true;
              "Nixpkgs" = {
                urls = singleton {
                  template = "https://search.nixos.org/packages";
                  params = attrsToList {
                    "channel" = "unstable";
                    "query" = "{searchTerms}";
                  };
                };
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };
              "NixOS Options" = {
                urls = singleton {
                  template = "https://search.nixos.org/options";
                  params = attrsToList {
                    "channel" = "unstable";
                    "query" = "{searchTerms}";
                  };
                };
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };
              "nix-darwin Options" = {
                urls = singleton {
                  template = "https://searchix.ovh/options/darwin/search";
                  params = attrsToList {
                    "query" = "{searchTerms}";
                  };
                };
                icon = "https://searchix.ovh/favicon.ico";
                definedAliases = [ "@ndo" ];
              };
              "Home Manager Options" = {
                urls = singleton {
                  template = "https://searchix.ovh/options/home-manager/search";
                  params = attrsToList {
                    "query" = "{searchTerms}";
                  };
                };
                icon = "https://searchix.ovh/favicon.ico";
                definedAliases = [ "@ho" ];
              };
            };
            containersForce = true;
            containers = {
              "Underlay" = {
                id = 1;
                color = "green";
                icon = "fence";
              };
              "Enthalpy" = {
                id = 2;
                color = "red";
                icon = "fence";
              };
            };
            userChrome = ''
              @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/userChrome.css";

              #TabsToolbar {
                display: none;
              }
            '';
            userContent = ''
              @import "${pkgs.firefox-gnome-theme}/share/firefox-gnome-theme/userContent.css";
            '';
          };
        };

      nixos =
        { ... }:
        {
          preservation.preserveAt = {
            state.users.${user.userName}.directories = [ ".mozilla" ];
          };
        };
    };
}
