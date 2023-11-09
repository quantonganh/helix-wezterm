#!/bin/bash

selected_file=$1
top_pane_id=$(wezterm cli get-pane-direction Up)
if [ -z "$selected_file" ]; then
    if [ -n "${top_pane_id}" ]; then
        wezterm cli activate-pane-direction --pane-id $top_pane_id Up
        wezterm cli zoom-pane --pane-id $top_pane_id
    fi
    exit 0
fi

if [ -z "${top_pane_id}" ]; then
    top_pane_id=$(wezterm cli split-pane --top)
fi

wezterm cli activate-pane-direction --pane-id $top_pane_id Up

send_to_top_pane="wezterm cli send-text --pane-id $top_pane_id --no-paste"

program=$(wezterm cli list --format json | jq --arg pane_id $top_pane_id -r '.[] | select(.pane_id  == ($pane_id | tonumber)) | .title')
if [[ "$program" == *"hx "* ]]; then
    echo -e ":open $selected_file\r" | $send_to_top_pane
else
    echo "hx $selected_file" | $send_to_top_pane
fi

# wezterm cli toggle-pane-zoom-state
