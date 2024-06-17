# helix-wezterm

Turning Helix into an IDE with the help of WezTerm and CLI tools

![Helix as IDE](https://github.com/quantonganh/blog-posts/blob/main/2023/08/19/hx-ide.gif)

## Features

The following sub-commands to helix-wezterm.sh are available:

 * `blame` Uses `tig` to open a "Git blame" in a split view for the current line
 * `check` Runs `cargo check` in a split window
 * `exlorer` Runs `broot` in left-side pane to open file explorer
 * `lazygit` Runs `lazygit` is split pane.
 * `fzf` Runs ripgrep to search through every line in the project. Similar to global_search
 * `howdoi` Runs `howdoi` with clipboard contents in a new split window.
 * `open` Uses `gh browse` to open the current file and line number on Github
 * `run` Calls commands in a new split window. See source code details.
 * `test_all` Runs all tests with `go test` in new split window
 * `test_single` Runs a single test in new pane based for the current file using `cargo test`
 * `tgpt` Runs `tgpt` with clipboard contents in new pane.

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

Install the requirements:

- [bat](https://github.com/sharkdp/bat) for file previews
- [broot](https://github.com/Canop/broot)
- [fish shell](https://fishshell.com/)
- [gh](https://cli.github.com/)
- [howdoi](https://github.com/gleitz/howdoi)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [ripgrep](https://github.com/BurntSushi/ripgrep) for grep-like searching
- [tig](https://jonas.github.io/tig/)
- [tgpt](https://github.com/aandrew-me/tgpt)

Add the following into `~/.config/helix/config.toml`:

```toml
[keys.normal.space.","]
b = ":sh helix-wezterm.sh blame"
c = ":sh helix-wezterm.sh check"
e = ":sh helix-wezterm.sh explorer"
f = ":sh helix-wezterm.sh fzf"
g = ":sh helix-wezterm.sh lazygit"
o = ":sh helix-wezterm.sh open"
r = ":sh helix-wezterm.sh run"
s = ":sh helix-wezterm.sh test_single"
t = ":sh helix-wezterm.sh test_all"
```
