{ self, inputs, ... }: {
  flake.nixosModules.portals = { pkgs, ... }: {
    # niri exposes screencasting through the org.gnome.Mutter.ScreenCast
    # D-Bus interface, which xdg-desktop-portal-gnome knows how to talk to.
    # xdg-desktop-portal-wlr does NOT support niri -- don't substitute it in.
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
      config.common.default = [ "gnome" "gtk" ];
    };
  };
}
