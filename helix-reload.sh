#!/bin/sh

hx_pane_id=$1
echo -e ":reload\r" | wezterm cli send-text --pane-id $hx_pane_id --no-paste
