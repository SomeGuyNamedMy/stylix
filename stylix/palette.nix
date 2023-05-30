{ palette-generator, base16 }:
{ pkgs, lib, config, ... }@args:

with lib;

let
  fromOs = import ./fromos.nix { inherit lib args; };

  cfg = config.stylix;

  paletteJSON = let
    generatedJSON = pkgs.runCommand "palette.json" { } ''
      ${palette-generator}/bin/palette-generator ${cfg.polarity} ${cfg.wallpaper.image} $out
    '';
    palette = importJSON generatedJSON;
    scheme = base16.mkSchemeAttrs palette;
    json = scheme {
      template = ./palette.json.mustache;
      extension = ".json";
    };
  in json;
  generatedScheme = importJSON paletteJSON;

  override =
    (if cfg.base16Scheme == fromOs [ "base16Scheme" ] {}
     then fromOs [ "override" ] {}
     else {}) 
    // cfg.override;

in {
  # TODO link to doc on how to do instead
  imports = [
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base00" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base01" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base02" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base03" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base04" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base05" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base06" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base07" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base08" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base09" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0A" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0B" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0C" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0D" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0E" ] "Using stylix.palette to override scheme is not supported anymore")
    (lib.mkRemovedOptionModule [ "stylix" "palette" "base0F" ] "Using stylix.palette to override scheme is not supported anymore")
  ];

  options.stylix = {
    polarity = mkOption {
      type = types.enum [ "either" "light" "dark" ];
      default = fromOs [ "polarity" ] "either";
      description = mdDoc ''
        Use this option to force a light or dark theme.

        By default we will select whichever is ranked better by the genetic
        algorithm. This aims to get good contrast between the foreground and
        background, as well as some variety in the highlight colours.
      '';
    };

    image = mkOption {
      type = types.coercedTo types.package toString types.path;
      description = mdDoc ''
        Wallpaper image.

        This is set as the background of your desktop environment, if possible,
        and used to generate a colour scheme if you don't set one manually.
      '';
      default = fromOs [ "image" ] null;
    };

    wallpaper = mkOption {
        type = with types; with config.lib.stylix; types.oneOf [static animation video slideshow];
        description = ''
        Wallpaper image.

        This is set as the background of your desktop environment, if possible,
        and used to generate a colour scheme if you don't set one manually.
        '';
    };

    generated = {
      json = mkOption {
        type = types.path;
        description = "The result of palette-generator.";
        readOnly = true;
        internal = true;
        default = paletteJSON;
      };

      palette = mkOption {
        type = types.attrs;
        description = "The imported json";
        readOnly = true;
        internal = true;
        default = generatedScheme;
      };
    };

    base16Scheme = mkOption {
      description = mdDoc ''
        A scheme following the base16 standard.

        This can be a path to a file, a string of YAML, or an attribute set.
      '';
      type = with types; oneOf [ path lines attrs ];
      default =
        if args ? "osConfig" && cfg.wallpaper.image != args.osConfig.stylix.image
          then generatedScheme
          else fromOs [ "base16Scheme" ] generatedScheme;
      defaultText = literalMD ''
        The colors used in the theming.

        Those are automatically selected from the background image by default,
        but could be overridden manually.
      '';
    };
    
    override = mkOption {
      description = mdDoc ''
        An override that will be applied to stylix.base16Scheme when generating
        lib.stylix.colors.

        Takes anything that a scheme generated by base16nix can take as argument
        to override.
      '';
      type = types.attrs;
      default = {};
    };
  };

  config = {
    # This attrset can be used like a function too, see
    # https://github.com/SenchoPens/base16.nix#mktheme
    lib.stylix.colors = (base16.mkSchemeAttrs cfg.base16Scheme).override override;
    lib.stylix.scheme = base16.mkSchemeAttrs cfg.base16Scheme;
  };
}
