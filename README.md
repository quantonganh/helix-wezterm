# helix-wezterm
Turning Helix into an IDE with the help of WezTerm and CLI tools

![Helix as IDE](https://github.com/quantonganh/blog/blob/master/2023/08/19/hx-ide.gif)

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

- [broot](https://github.com/Canop/broot)
- [gh](https://cli.github.com/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [tig](https://jonas.github.io/tig/)

Add the following into `~/.config/helix/config.toml`:

```toml
[keys.normal.";"]
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