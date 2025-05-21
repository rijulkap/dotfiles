# Get Rid of greeting
set fish_greeting

# Set vi mode
fish_vi_key_bindings

# Set editor env variable
export EDITOR="nvim"

# Starship init
function starship_transient_prompt_func
  starship module character
end
starship init fish | source
enable_transience

# Yazi
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# Zoxide
zoxide init fish | source
