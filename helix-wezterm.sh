#!/bin/sh

set -x

status_line=$(wezterm cli get-text | rg -e "(?:NOR\s+|NORMAL|INS\s+|INSERT|SEL\s+|SELECT)\s+[\x{2800}-\x{28FF}]*\s+(\S*)\s[^│]* (\d+):*.*" -o --replace '$1 $2')
filename=$(echo $status_line | awk '{ print $1}')
line_number=$(echo $status_line | awk '{ print $2}')

split_pane_down() {
  bottom_pane_id=$(wezterm cli get-pane-direction down)
  if [ -z "${bottom_pane_id}" ]; then
    bottom_pane_id=$(wezterm cli split-pane)
  fi

  wezterm cli activate-pane-direction --pane-id $bottom_pane_id down

  send_to_bottom_pane="wezterm cli send-text --pane-id $bottom_pane_id --no-paste"
  program=$(wezterm cli list | awk -v pane_id="$bottom_pane_id" '$3==pane_id { print $6 }')
  if [ "$program" = "lazygit" ]; then
    echo "q" | $send_to_bottom_pane
  fi
}

pwd=$PWD
basedir=$(dirname "$filename")
basename=$(basename "$filename")
basename_without_extension="${basename%.*}"
extension="${filename##*.}"

case "$1" in
  "blame")
    split_pane_down
    echo "cd $pwd; tig blame $filename +$line_number" | $send_to_bottom_pane
    ;;
  "check")
    split_pane_down
    case "$extension" in
      "rs")
        run_command="cd $pwd/$(echo $filename | sed 's|src/.*$||'); cargo check; if [ \$status = 0 ]; wezterm cli activate-pane-direction up; end;"
        ;;
    esac
    echo "$run_command" | $send_to_bottom_pane
    ;;
  "explorer")
    left_pane_id=$(wezterm cli get-pane-direction left)
    if [ -z "${left_pane_id}" ]; then
      left_pane_id=$(wezterm cli split-pane --left --percent 20)
    fi

    left_program=$(wezterm cli list | awk -v pane_id="$left_pane_id" '$3==pane_id { print $6 }')
    if [ "$left_program" != "br" ]; then
      echo "br" | wezterm cli send-text --pane-id $left_pane_id --no-paste
    fi

    wezterm cli activate-pane-direction left
    ;;
  "fzf")
    split_pane_down
    echo "cd $pwd; hx-fzf.sh \$(rg --line-number --column --no-heading --smart-case . | fzf --delimiter : --preview 'bat --style=full --color=always --highlight-line {2} {1}' --preview-window '~3,+{2}+3/2' | awk '{ print \$1 }' | cut -d: -f1,2,3)" | $send_to_bottom_pane
    ;;
  "howdoi")
    split_pane_down
    echo "howdoi -c `pbpaste`" | $send_to_bottom_pane
    ;;
  "lazygit")
    split_pane_down
    program=$(wezterm cli list | awk -v pane_id="$pane_id" '$3==pane_id { print $6 }')
    if [ "$program" = "lazygit" ]; then
        wezterm cli activate-pane-direction down
    else
        echo "cd $pwd; lazygit" | $send_to_bottom_pane
    fi
    ;;
  "open")
    gh browse $filename:$line_number  
    ;;
  "run")
    split_pane_down
    case "$extension" in
      "c")
        run_command="clang -lcmocka -lmpfr -Wall -g -O1 $filename -o $basedir/$basename_without_extension && $basedir/$basename_without_extension"
        ;;
      "go")
        run_command="go run $basedir/*.go"
        ;;
      "md")
        run_command="mdcat -p $filename"
        ;;
      "rkt"|"scm")
        run_command="racket $filename"
        ;;
      "rs")
        run_command="cd $pwd/$(echo $filename | sed 's|src/.*$||'); cargo run; if [ \$status = 0 ]; wezterm cli activate-pane-direction up; end"
        ;;
      "sh")
        run_command="sh $filename"
        ;;
    esac
    echo "$run_command" | $send_to_bottom_pane
    ;;
  "test_all")
    split_pane_down
    case "$extension" in
      "go")
        run_command="go test -v ./...; if [ \$status = 0 ]; wezterm cli activate-pane-direction up; end;"
        ;;
      "rs")
        run_command="cd $pwd/$(echo $filename | sed 's|src/.*$||'); cargo test; if [ \$status = 0 ]; wezterm cli activate-pane-direction up; end;"
        ;;
    esac
    echo "$run_command" | $send_to_bottom_pane
    ;;
  "test_single")
    test_name=$(head -$line_number $filename | tail -1 | sed -n 's/^.*fn \([^ ]*\)().*$/\1/p')
    split_pane_down
    case "$extension" in
      "rs")
        run_command="cd $pwd/$(echo $filename | sed 's|src/.*$||'); cargo test $test_name; if [ \$status = 0 ]; wezterm cli activate-pane-direction up; end;"
        ;;
    esac
    echo "$run_command" | $send_to_bottom_pane
    ;;
  "tgpt")
    split_pane_down
    echo "tgpt '`pbpaste`'" | $send_to_bottom_pane
    ;;
esac
