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

    choice=$(printf "Yes\nNo\nQuit" | gum choose --height=3 --limit 1 --header "Accept suggestion?" --selected No)
    case "$choice" in
        Yes)
            break
            ;;
        No)
            continue
            ;;
        Quit|"")
            exit 0
            ;;
    esac
done

wezterm cli send-text --pane-id $HX_PANE_ID --no-paste -- ":"
wezterm cli send-text --pane-id $HX_PANE_ID -- "pipe hxide-aichat-last-reply.sh $session"
printf "\r" | wezterm cli send-text --pane-id $HX_PANE_ID --no-paste
