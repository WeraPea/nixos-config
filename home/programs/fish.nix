{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      export MANPAGER='nvim +Man!'
      set fish_greeting
      bind ! __history_previous_command
    '';
    functions = {
      __history_previous_command.body = ''
        switch (commandline -t)
        case "!"
          commandline -t $history[1]; commandline -f repaint
        case "*"
          commandline -i !
        end
      '';
      fish_prompt.body = ''
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
            set -g __fish_git_prompt_char_dirtystate ""
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
      ns = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      nt = "sudo nixos-rebuild test --flake ~/nixos#nixos";
      sl = "ll";
      vim = "nvim";
      vm = "mv";
      x = "exit";
    };
  };
}
