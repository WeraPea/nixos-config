{
  lib,
  yt-sub-converter,
  mpvScripts,
}:
let
  version = "2026.01.22";
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

        local function strip_backgrounds(ass_file)
            local f = io.open(ass_file, "r")
            if not f then return end
            local content = f:read("*all")
            f:close()

            -- Change BorderStyle from 3 to 1 AND set Outline from 0.01 to 2
            content = content:gsub("(Style: YT%w*Box,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,)3,([%d%.]+)", "%11,2")
            -- sadly the border will appear before the karaoke timings, but still better than a whole box doing so too

            f = io.open(ass_file, "w")
            f:write(content)
            f:close()
        end

        local function build_ytdlp_base_cmd(path, tmpdir_path)
            local cmd = {
                "yt-dlp",
                "--skip-download",
                "--write-subs",
                "--sub-langs", "en",
                "--sub-format", "srv3",
                "-o", tmpdir_path .. "/subs.%(ext)s",
                path
            }

            if o.cookies_from_browser ~= "" then
              table.insert(cmd, "--cookies-from-browser")
              table.insert(cmd, o.cookies_from_browser)
            elseif o.cookies ~= "" then
              table.insert(cmd, "--cookies")
              table.insert(cmd, o.cookies)
            end

            return cmd
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

            local manual_cmd = build_ytdlp_base_cmd(path, tmpdir)

            local srv3_path = tmpdir .. "/subs.en.srv3"
            local sub_ass_path = tmpdir .. "/subs.en.ass"
            local has_manual = false

            if utils.file_info(srv3_path) ~= nil then
                local convert_cmd = {"YTSubConverter", srv3_path}
                local convert_res = utils.subprocess({args = convert_cmd})

                if convert_res.status == 0 then
                    has_manual = true
                    mp.commandv("sub-add", sub_ass_path)
                    mp.msg.info("Loaded manual subtitles")
                end
            end

            if not has_manual then
                os.execute("rm -f " .. srv3_path)
                os.execute("rm -f " .. sub_ass_path)

                local auto_cmd = build_ytdlp_base_cmd(path, tmpdir)
                table.insert(auto_cmd, "--write-auto-subs")
                utils.subprocess({args = auto_cmd})

                if utils.file_info(srv3_path) ~= nil then
                    local convert_cmd = {"YTSubConverter", srv3_path}
                    local convert_res = utils.subprocess({args = convert_cmd})

                    if convert_res.status == 0 then
                        strip_backgrounds(sub_ass_path)
                        mp.commandv("sub-add", sub_ass_path)
                        mp.msg.info("Loaded auto-generated subtitles (backgrounds stripped)")
                    end
                end
            end
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
