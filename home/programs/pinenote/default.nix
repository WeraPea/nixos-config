{ lib, config, ... }:
{
  imports = [
    ./sway.nix
    ./waybar.nix
    ./switch-boot-partition.nix
  ];
  options = {
    pinenote.enable = lib.mkEnableOption "enables pinenote config";
  };
  config = lib.mkIf config.pinenote.enable {
    pinenote-sway.enable = true;
    pinenote-waybar.enable = true;
    xdg.configFile."nwg-launchers/nwggrid/grid.conf".text = ''
      {
        "categories": { },
        "favorites" : false,
        "pins" : false,
        "columns" : 6,
        "icon-size" : 72,
        "no-categories": true,
        "oneshot" : false
      }
    '';
    # "custom-path" : "/my/path1:/my/another path:/third/path",

    xdg.configFile."nwg-launchers/nwggrid/style.css".text = ''
      * {
      }
    '';
    #   button, label, image {
    #       background: none;
    #       border-style: none;
    #       box-shadow: none;
    #       color: #999;
    #   }
    #
    #   button {
    #       padding: 5px;
    #       margin: 5px;
    #       text-shadow: none;
    #   }
    #
    #   button:hover {
    #       background-color: rgba (255, 255, 255, 0.1);
    #   }
    #
    #   button:focus {
    #       box-shadow: 0 0 10px;
    #   }
    #
    #   button:checked {
    #       background-color: rgba (255, 255, 255, 0.1);
    #   }
    #
    #   #searchbox {
    #       background: none;
    #       border-color: #999;
    #       color: #ccc;
    #       margin-top: 20px;
    #       margin-bottom: 20px
    #   }
    #
    #   #separator {
    #       background-color: rgba(200, 200, 200, 0.5);
    #       margin-left: 500px;
    #       margin-right: 500px;
    #       margin-top: 10px;
    #       margin-bottom: 10px
    #   }
    #
    #   #description {
    #       margin-bottom: 20px
    #   }
    # '';
  };
}
