#!/bin/sh

set -x

filename=$1
line_number=$2

remote_url=$(git config remote.origin.url)
if [[ $remote_url == *"github.com"* ]]; then
  gh browse $filename:$line_number
else
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ $remote_url == "git@"* ]]; then
    open $(echo $remote_url | sed -e 's|:|/|' -e 's|\.git||' -e 's|git@|https://|')/-/blob/${current_branch}/${filename}#L${line_number}
  else
    open $(echo $remote_url | sed -e 's|\.git||')/-/blob/${current_branch}/${filename}#L${line_number}
  fi
fi
