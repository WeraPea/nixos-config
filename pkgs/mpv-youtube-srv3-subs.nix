{
  lib,
  yt-sub-converter,
  mpvScripts,
}:
let
  version = "2026.01.05";
  script =
    builtins.toFile "youtube-srv3-subs.lua" # lua
      ''
        local options = require 'mp.options'
        local utils = require 'mp.utils'
        local tmpdir = nil
        local o = {
          cookies = "",
          cookies_from_browser = "",
        }
        options.read_options(o, "mpv-youtube-srv3-subs")

        local function safe_rm(path)
          if path and path:match("^/tmp/") then
            os.execute("rm -rf " .. path)
          end
        end

        mp.register_event("start-file", function()
            local path = mp.get_property("path")
            if not path or not path:match("^https?://") then return end
            if not path:match("youtube%.com") and not path:match("youtu%.be") then return end
            local mktemp_res = utils.subprocess({args = {"mktemp", "-d"}})

            if mktemp_res.status ~= 0 or not mktemp_res.stdout then
              mp.msg.error("Failed to create temporary directory")
              return
            end
            tmpdir = mktemp_res.stdout:gsub("%s+$", "")


            local srv3_path = tmpdir .. "/subs.en.srv3"
            local sub_ass_path = tmpdir .. "/subs.en.ass"

            local ytdlp_cmd = {
                "yt-dlp",
                "--skip-download",
                "--write-subs",
                "--sub-langs", "en",
                "--sub-format", "srv3",
                "-o", tmpdir .. "/subs.%(ext)s",
                path
            }
            if o.cookies_from_browser ~= "" then
              table.insert(ytdlp_cmd, "--cookies-from-browser")
              table.insert(ytdlp_cmd, o.cookies_from_browser)
            elseif o.cookies ~= "" then
              table.insert(ytdlp_cmd, "--cookies")
              table.insert(ytdlp_cmd, o.cookies)
            end

            utils.subprocess({args = ytdlp_cmd})

            if utils.file_info(srv3_path) == nil then
              safe_rm(tmpdir)
              return
            end

            local convert_cmd = {
                "YTSubConverter",
                srv3_path
            }
            local convert_res = utils.subprocess({args = convert_cmd})
            if convert_res.status ~= 0 then
              mp.msg.error("Subtitle conversion failed: " .. (convert_res.stderr or "unknown error"))
              safe_rm(tmpdir)
              return
            end

            mp.commandv("sub-add", sub_ass_path)
        end)

        mp.register_event("end-file", function()
          safe_rm(tmpdir)
        end)

        mp.register_event("shutdown", function()
          safe_rm(tmpdir)
        end)
      '';

in
mpvScripts.buildLua {
  pname = "mpv-youtube-srv3-subs";
  inherit version;

  src = script;
  unpackPhase = ''
    runHook preUnpack

    mkdir -p source
    cp $src source/youtube-srv3-subs.lua
    cd source

    runHook postUnpack
  '';

  postPatch = ''
    ls -al
    pwd
    substituteInPlace youtube-srv3-subs.lua \
      --replace-fail "YTSubConverter" "${lib.getExe yt-sub-converter}"
  '';

  meta = with lib; {
    description = "Convert youtube srv3 subs to vtt on the fly.";
    platforms = platforms.all;
    license = licenses.mit;
  };
}
