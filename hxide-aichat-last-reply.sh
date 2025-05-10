#/usr/bin/env bash

session=$1
aichat --session "$session" --info | yq '.messages | map(select(.role == "assistant")) | .[-1].content' | awk '/^```/{f=!f; next} f'
