{ self, inputs, ... }: {
  # noctalia-shell scans Settings.configDir + "colorschemes" (a plain
  # writable dir, unlike the read-only preinstalled schemes bundled in the
  # package) for extra */scheme.json entries at every launch, so dropping
  # one here is enough for noctalia-laptop.json's predefinedScheme:
  # "Everforest" to resolve -- no download/plugin step needed.
  flake.homeModules.noctaliaTheme = { lib, hostName, ... }: {
    xdg.configFile."noctalia/colorschemes/Everforest/Everforest.json" = lib.mkIf (hostName == "nixbook") {
      source = ../../assets/noctalia-everforest-scheme.json;
    };
  };
}
