install:
	mkdir -p ~/.local/bin
	cp helix-wezterm.sh ~/.local/bin
	cp helix-fzf.sh ~/.local/bin

uninstall:
	rm -f ~/.local/bin/helix-wezterm.sh
	rm -f ~/.local/bin/helix-fzf.sh
