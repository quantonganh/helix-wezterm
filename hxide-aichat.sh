#/usr/bin/env bash

selection=$(cat)
session=$1

while true; do
    prompt="$(gum input --placeholder 'Ask anything')"
    if [ $? -ne 0 ]; then
        exit 0
    fi

    echo "$selection" | aichat --code --session "$session" "$prompt" || exit 1

    echo

    gum confirm "Accept suggestion?" --default=No
    exit_code=$?

    if [ $exit_code -eq 0 ]; then
        break
    elif [ $exit_code -eq 1 ]; then
        continue
    else
        exit 0
    fi
done

wezterm cli send-text --pane-id $HX_PANE_ID --no-paste -- ":"
wezterm cli send-text --pane-id $HX_PANE_ID -- "pipe hxide-aichat-last-reply.sh $session"
printf "\r" | wezterm cli send-text --pane-id $HX_PANE_ID --no-paste
