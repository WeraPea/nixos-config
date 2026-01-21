{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    fish.enable = lib.mkEnableOption "enables fish";
  };
  config = lib.mkIf config.fish.enable {
    programs.nix-your-shell.enable = true;
    programs.fish = {
      enable = true;
      interactiveShellInit = # fish
        ''
          export NVIMPAGER_NVIM="${config.home.sessionVariables.NVIMPAGER_NVIM}"
          export PAGER="${lib.getExe pkgs.nvimpager}"
          export SYSTEMD_PAGERSECURE="true";
          set fish_greeting
          bind ! __history_previous_command
        '';
      functions = {
        fish_user_key_bindings.body = # fish
          ''
            bind -M default H beginning-of-line
            bind -M default L end-of-line
            fish_default_key_bindings -M insert
            fish_vi_key_bindings --no-erase insert
          '';
        __history_previous_command.body = # fish
          ''
            switch (commandline -t)
            case "!"
              commandline -t $history[1]; commandline -f repaint
            case "*"
              commandline -i !
            end
          '';
        fish_prompt.body = # fish
          ''
            set -l last_pipestatus $pipestatus

            if not set -q __fish_git_prompt_show_informative_status
                set -g __fish_git_prompt_show_informative_status 1
            end
            if not set -q __fish_git_prompt_hide_untrackedfiles
                set -g __fish_git_prompt_hide_untrackedfiles 1
            end
            if not set -q __fish_git_prompt_color_branch
                set -g __fish_git_prompt_color_branch magenta --bold
            end
            if not set -q __fish_git_prompt_showupstream
                set -g __fish_git_prompt_showupstream "informative"
            end
            if not set -q __fish_git_prompt_char_upstream_ahead
                set -g __fish_git_prompt_char_upstream_ahead "↑"
            end
            if not set -q __fish_git_prompt_char_upstream_behind
                set -g __fish_git_prompt_char_upstream_behind "↓"
            end
            if not set -q __fish_git_prompt_char_upstream_prefix
                set -g __fish_git_prompt_char_upstream_prefix " "
            end
            if not set -q __fish_git_prompt_char_stagedstate
                set -g __fish_git_prompt_char_stagedstate ""
            end
            if not set -q __fish_git_prompt_char_dirtystate
                set -g __fish_git_prompt_char_dirtystate "󰐕"
            end
            if not set -q __fish_git_prompt_char_untrackedfiles
                set -g __fish_git_prompt_char_untrackedfiles "…"
            end
            if not set -q __fish_git_prompt_char_invalidstate
                set -g __fish_git_prompt_char_invalidstate ""
            end
            if not set -q __fish_git_prompt_char_cleanstate
                set -g __fish_git_prompt_char_cleanstate ""
            end
            if not set -q __fish_git_prompt_color_dirtystate
                set -g __fish_git_prompt_color_dirtystate blue
            end
            if not set -q __fish_git_prompt_color_stagedstate
                set -g __fish_git_prompt_color_stagedstate yellow
            end
            if not set -q __fish_git_prompt_color_invalidstate
                set -g __fish_git_prompt_color_invalidstate red
            end
            if not set -q __fish_git_prompt_color_untrackedfiles
                set -g __fish_git_prompt_color_untrackedfiles $fish_color_normal
            end
            if not set -q __fish_git_prompt_color_cleanstate
                set -g __fish_git_prompt_color_cleanstate green --bold
            end

            set -l nix_shell_info (
              if test -n "$IN_NIX_SHELL"
                echo -n "(nix-shell) "
              end
            )
            set_color 7EB6E2
            echo -n $nix_shell_info
            set_color normal

            set -l color_cwd
            set -l prefix
            set -l suffix
            switch "$USER"
                case root toor
                    if set -q fish_color_cwd_root
                        set color_cwd $fish_color_cwd_root
                    else
                        set color_cwd $fish_color_cwd
                    end
                    set suffix '#'
                case '*'
                    set color_cwd $fish_color_cwd
                    set suffix 'λ'
            end

            # PWD
            set_color $color_cwd
            echo -n (prompt_pwd)
            set_color normal

            printf '%s ' (fish_vcs_prompt)

            set -l pipestatus_string (__fish_print_pipestatus "[" "] " "|" (set_color $fish_color_status) (set_color --bold $fish_color_status) $last_pipestatus)
            echo -n $pipestatus_string
            set_color normal

            echo -n "$suffix "
          '';
      };
      shellAbbrs = {
        cl = "clear";
        dc = "cd";
        lc = "clear";
        ls = "ll";
        ns = "nh os switch ~/nixos-config -k";
        nt = "nh os test ~/nixos-config -k";
        rnts = "rsync -ar --delete ~/nixos-config/ server:~/nixos-config-temp && ssh -t server nh os test ~/nixos-config-temp -k";
        rnss = "rsync -ar --delete ~/nixos-config/ server:~/nixos-config-temp && ssh -t server nh os switch ~/nixos-config-temp -k";
        rntl = "rsync -ar --delete ~/nixos-config/ nixos-laptop:~/nixos-config-temp && ssh -t nixos-laptop nh os test ~/nixos-config-temp -k";
        rnsl = "rsync -ar --delete ~/nixos-config/ nixos-laptop:~/nixos-config-temp && ssh -t nixos-laptop nh os switch ~/nixos-config-temp -k";
        rntf = "rsync -ar --delete ~/nixos-config/ fajita:~/nixos-config-temp && ssh -t fajita nh os test ~/nixos-config-temp -k";
        rnsf = "rsync -ar --delete ~/nixos-config/ fajita:~/nixos-config-temp && ssh -t fajita nh os switch ~/nixos-config-temp -k";
        nts = "nh os test -H server ~/nixos-config --target-host server -k";
        nss = "nh os switch -H server ~/nixos-config --target-host server -k";
        ntl = "nh os test -H nixos-laptop ~/nixos-config --target-host nixos-laptop -k";
        nsl = "nh os switch -H nixos-laptop ~/nixos-config --target-host nixos-laptop -k";
        ntp = "nh os test -H pinenote-from-x86_64 ~/nixos-config --target-host pinenote -k -o ~/nh-os-pinenote-(date -Is)";
        nsp = "nh os switch -H pinenote-from-x86_64 ~/nixos-config --target-host pinenote -k -o ~/nh-os-pinenote-(date -Is)-switch";
        sl = "ll";
        vim = "nvim";
        vm = "mv";
        x = "exit";
        rp = "rsync -avh --info=progress2 --no-inc-recursive";
        riw = "nix-shell -p efibootmgr --run 'sudo efibootmgr -n 0001'";
        ssc = {
          setCursor = "%";
          expansion = "kitty +kitten ssh -t % fish -i";
        };
        lsblkk = "lsblk -o name,mountpoint,fsuse%,fsused,fsavail,fssize,model,label";
        ng = "nvim +:Neogit";
      };
    };
  };
}
