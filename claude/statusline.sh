#!/usr/bin/env bash

input=$(cat)

# Session name - read custom title from transcript file
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
session_name=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  session_name=$(grep '"type":"custom-title"' "$transcript_path" 2>/dev/null | tail -1 | jq -r '.customTitle // empty' 2>/dev/null)
fi
if [ -z "$session_name" ]; then
  session_name="unnamed"
fi

# Current directory
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')

# Model name
model_name=$(echo "$input" | jq -r '.model.display_name // empty')

# Context window used percentage
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$context_used" ]; then
  context_display="${context_used}%"
else
  context_display="N/A"
fi

# Git branch
git_branch=""
if [ -n "$current_dir" ] && [ -d "$current_dir" ]; then
  git_branch=$(cd "$current_dir" && git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)
fi

# Build output
output="$session_name"

if [ -n "$git_branch" ]; then
  output="$output | $git_branch"
fi

output="$output | Ctx: $context_display | $model_name"

if [ -n "$current_dir" ]; then
  short_dir="${current_dir/#$HOME/~}"
  output="$output | $short_dir"
fi

printf "%s" "$output"
