# helix-wezterm

[Turning Helix into an IDE with the help of WezTerm and CLI tools](https://quantonganh.com/2023/08/19/turn-helix-into-ide.md)

![Helix as IDE](https://github.com/quantonganh/blog-posts/blob/main/2023/08/19/hx-ide.gif)

## Installation

You can simply download [helix wezterm.sh](./helix-wezterm.sh) and [helix-fzf.sh](./helix-fzf.sh) to `~/.local/bin` and then add this directory to your `$PATH`.

### Install via homebrew

```
$ brew install quantonganh/tap/helix-wezterm
```

### Install via [bpkg](https://github.com/bpkg/bpkg)

```sh
$ bpkg install quantonganh/helix-wezterm -g
```

## Usage

```sh
./helix-wezterm.sh -h
Usage: ./helix-wezterm.sh <action> [OPTIONS]

Options:
  -h, --help      Display this help message and exit

Available actions:
- blame: Show blame for the current file and line number
- explorer: Open the file explorer
- generate_tests: Generate Go tests for the current file
- lazygit: Open terminal UI for git commands
- lint: Lint the current file
- mock: Generate mocks
- navi: Open an interactive cheatsheet tool
- open: Open the current file and line number in the web browser
- present: Present the current file
- query: Query database
- run: Run the current file
- slumber: Open a HTTP client
- test: Test the current file
```

Download [the configuration file](.helix-wezterm.yaml), and place it in either `$XDG_CONFIG_HOME` if set, or `$HOME` directory.
Customize the file to specify which CLI tool you want to use for each action.

Install the following requirements:

- [envsubst](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)
- [yq](https://github.com/mikefarah/yq)

Additionally, it's recommended to install the following CLI tools:

- [aichat](https://github.com/sigoden/aichat)
- [bat](https://github.com/sharkdp/bat) for file previews
- [fish shell](https://fishshell.com/)
- [fzf](https://github.com/junegunn/fzf)
- [gh](https://cli.github.com/)
- [glow](https://github.com/charmbracelet/glow)
- [gum](https://github.com/charmbracelet/gum)
- [hurl](https://hurl.dev/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [lazysql](https://github.com/jorgerojas26/lazysql)
- [mods](https://github.com/charmbracelet/mods)
- [navi](https://github.com/denisidoro/navi)
- [presenterm](https://github.com/mfontanini/presenterm)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for grep-like searching
- [slumber](https://github.com/LucasPickering/slumber)
- [tig](https://jonas.github.io/tig/)
- [yazi](https://github.com/sxyazi/yazi)

Add the following into `~/.config/helix/config.toml`:

```toml
[keys.normal.space.","]
b = ":sh helix-wezterm.sh blame"
c = ":sh helix-wezterm.sh check"
e = ":sh helix-wezterm.sh explorer"
g = ":sh helix-wezterm.sh lazygit"
o = ":sh helix-wezterm.sh open"
q = ":sh helix-wezterm.sh query"
r = ":sh helix-wezterm.sh run"
s = ":sh helix-wezterm.sh slumber"
m = ":sh helix-wezterm.sh mock"
n = ":sh helix-wezterm.sh navi"
p = ":sh helix-wezterm.sh present"
t = ":sh helix-wezterm.sh test"

[keys.select.";"]
a = [
    "yank_to_clipboard",
    ":sh helix-wezterm.sh ai"
]
```
