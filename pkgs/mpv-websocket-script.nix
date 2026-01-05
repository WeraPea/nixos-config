{
  lib,
  mpvScripts,
  mpv-websocket,
  writeTextDir,
}:
mpvScripts.buildLua {
  pname = "mpv-websocket-script";
  version = "0.4.3"; # surely i won't forget to change this when flake input updates…

  src =
    writeTextDir "websocket-script.lua" # lua
      ''
        local mpv_websocket_path = "${lib.getExe' mpv-websocket "mpv_websocket"}"
        local initialised_websocket

        local function find_mpv_socket()
          local mpv_socket = mp.get_property("input-ipc-server")
          if not mpv_socket or mpv_socket == "" then
            error("input-ipc-server option is not set")
          end
          return mpv_socket
        end

        local mpv_socket = find_mpv_socket()

        local function start_websocket()
          initialised_websocket = mp.command_native_async({
            name = "subprocess",
            playback_only = false,
            args = {
              mpv_websocket_path,
              "-m",
              mpv_socket,
              "-w",
              "6677",
            },
          })
        end

        local function end_websocket()
          mp.abort_async_command(initialised_websocket)
          initialised_websocket = nil
        end

        local function toggle_websocket()
          local paused = mp.get_property_bool("pause")
          if initialised_websocket and paused then
            end_websocket()
          elseif not initialised_websocket and not paused then
            start_websocket()
          end
        end

        mp.register_script_message("togglewebsocket", toggle_websocket)
        start_websocket()
      '';

  meta = with lib; {
    description = "A WebSocket plugin for mpv ";
    homepage = "https://github.com/kuroahna/mpv_websocket";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
