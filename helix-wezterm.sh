#!/bin/sh

set -x

# Get the current filename and the line number from the status line
status_line=$(wezterm cli get-text | rg -e "(?:NORMAL|INSERT|SELECT)\s+[\x{2800}-\x{28FF}]*\s+(\S*)\s[^│]* (\d+):*.*" -o --replace '$1 $2')
export filename=$(echo $status_line | awk '{ print $1}')
export line_number=$(echo $status_line | awk '{ print $2}')

pwd=$(PWD)
export basedir=$(dirname "$filename")
basename=$(basename "$filename")
basename_without_extension="${basename%.*}"
extension="${filename##*.}"

# Load the configuration file
config_file="${HOME}/.config/helix-wezterm/config.yaml"

# Get the action from the first argument
action=$1

# Extract the direction, percent and command from the YAML configuration
direction=$(yq e ".actions.$action.direction" "$config_file")
if [ "$direction" == "null" ]; then
  direction=bottom
fi

percent=$(yq e ".actions.$action.percent" "$config_file")
if [ "$percent" == "null" ]; then
  percent=50
fi
command=$(yq e ".actions.$action.command" "$config_file")

case "$action" in
  "test")
    case "$extension" in
      "go")
        export test_name=$(head -$line_number $filename | tail -1 | sed -n 's/func \([^(]*\).*/\1/p')
        ;;
      "rs")
        export test_name=$(head -$line_number $filename | tail -1 | sed -n 's/^.*fn \([^ ]*\)().*$/\1/p')
        ;;
    esac
    ;;
esac
  
case "$direction" in
  "left")
    get_direction="left"
    ;;
  "right")
    get_direction="right"
    ;;
  "top")
    get_direction="up"
    ;;
  "bottom")
    get_direction="down"
    ;;
esac

# Split pane in direction
split_pane() {
  pane_id=$(wezterm cli get-pane-direction $get_direction)
  if [ -z "$pane_id" ]; then
    pane_id=$(wezterm cli split-pane --$direction --percent $percent)
  fi

  wezterm cli activate-pane-direction $get_direction
  send_to_pane="wezterm cli send-text --pane-id $pane_id --no-paste"
}

split_pane $direction

# Send command to the target pane
ext=$(yq e ".actions.$action.extensions" "$config_file")
if [ "$ext" != "null" ]; then
  extension="${filename##*.}"
  command=$(yq e ".actions.$action.extensions.$extension" "$config_file")
fi

echo $(echo $command | envsubst) | $send_to_pane
