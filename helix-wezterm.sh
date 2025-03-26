#!/bin/sh

# Get the action from the first argument
action=$1
export buffer_name=$2
export cursor_line=$3

pwd=$(PWD)
export basedir=$(dirname "$buffer_name")
export binary_output=$(basename $basedir)
basename=$(basename "$buffer_name")
basename_without_extension="${basename%.*}"
extension="${buffer_name##*.}"

# Load the configuration file
config_file="${XDG_CONFIG_HOME:-$HOME}/.helix-wezterm.yaml"

usage() {
    echo "Usage: $0 <action> [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help      Display this help message and exit"
    echo ""
    echo "Available actions:"
    yq eval '.actions | to_entries | .[] | "- \(.key): \(.value.description)"' $config_file
    exit 0
}

for arg in "$@"; do
  case $arg in
    -h|--help)
      usage
      ;;
  esac
done

# Extract the position, percent and command from the YAML configuration
position=$(yq e ".actions.$action.position" "$config_file")
if [ "$position" == "null" ]; then
  position="bottom"
fi

percent=$(yq e ".actions.$action.percent" "$config_file")
if [ "$percent" == "null" ]; then
  percent=50
fi
command=$(yq e ".actions.$action.command" "$config_file")

case "$action" in
  "ai")
    export session=$(basename "$pwd")_$(echo "$buffer_name" | tr "/" "_")
    ;;
  "mock")
    case "$extension" in
      "go")
        current_line=$(head -$cursor_line $buffer_name | tail -1)
        export interface_name=$(echo $current_line | sed -n 's/^type \([A-Za-z0-9_]*\) interface {$/\1/p')
        ;;
    esac
    ;;
  "open")
    remote_url=$(git config remote.origin.url)
    if [[ $remote_url == *"github.com"* ]]; then
      gh browse $buffer_name:$cursor_line
    else
      current_branch=$(git rev-parse --abbrev-ref HEAD)
      if [[ $remote_url == "git@"* ]]; then
        open $(echo $remote_url | sed -e 's|:|/|' -e 's|\.git||' -e 's|git@|https://|')/-/blob/${current_branch}/${buffer_name}#L${cursor_line}
      else
        open $(echo $remote_url | sed -e 's|\.git||')/-/blob/${current_branch}/${buffer_name}#L${cursor_line}
      fi
    fi
    ;;
  "test")
    case "$extension" in
      "go")
        export test_name=$(head -$cursor_line $buffer_name | tail -1 | sed -n 's/func \([^(]*\).*/\1/p')
        ;;
      "hurl")
        current_line=$(head -$cursor_line $buffer_name | tail -1)
        export entry=$(egrep 'POST|PATCH|PUT|DELETE|GET' $buffer_name | grep -n "$current_line" | awk -F: '{ print $1 }')
        ;;
      "rs")
        export test_name=$(head -$cursor_line $buffer_name | tail -1 | sed -n 's/^.*fn \([^ ]*\)().*$/\1/p')
        ;;
    esac
    ;;
  "run")
    case "$basename" in
      "justfile")
        export recipe=$(head -$cursor_line $buffer_name | tail -1 | sed -n 's/:$//')
        ;;
    esac
    ;;
esac
  
case "$position" in
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

# Create a new pane in a specified direction or as a floating pane
create_pane() {
  case "$position" in
    "floating")
      is_zoomed=$(wezterm cli list --format json | jq -r ".[] | select(.pane_id == $WEZTERM_PANE) | .is_zoomed")
      if [ "$is_zoomed" == "true" ]; then
        wezterm cli zoom-pane --unzoom
      fi
    
      pane_id=$(wezterm cli spawn --floating-pane)
      ;;
    "window")
      pane_id=$(wezterm cli spawn --cwd $pwd --new-window)
      ;;
    "tab")
      pane_id=$(wezterm cli spawn --cwd $pwd)
      ;;
    *)
      pane_id=$(wezterm cli get-pane-direction $get_direction)
      if [ -z "$pane_id" ]; then
        pane_id=$(wezterm cli split-pane --$position --percent $percent)
      fi
      ;;
  esac

  wezterm cli activate-pane --pane-id $pane_id
  send_to_pane="wezterm cli send-text --pane-id $pane_id --no-paste"
}

act=$(yq e ".actions.$action" "$config_file")
if [ "$act" != "null" ]; then
  create_pane

  # Send command to the target pane
  ext=$(yq e ".actions.$action.extensions" "$config_file")
  if [ "$ext" != "null" ]; then
    extension="${buffer_name##*.}"
    command=$(yq e ".actions.$action.extensions.$extension" "$config_file")
  fi

  expanded_command=$(echo $command | envsubst '$WEZTERM_PANE,$basedir,$binary_output,$buffer_name,$cursor_line,$interface_name,$test_name,$session,$entry')
  echo "$expanded_command\r" | $send_to_pane
fi
