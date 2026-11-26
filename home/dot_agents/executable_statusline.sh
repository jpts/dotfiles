#!/usr/bin/env bash

# ==============================================================================
# Unified Statusline Hook Script
# ==============================================================================

# Read JSON from stdin
PAYLOAD=$(cat)

# Extract active model name
MODEL_NAME=$(echo "$PAYLOAD" | jq -r '
  .model.display_name //
  .model.id //
  "Unknown Model"
' 2>/dev/null)

EFFORT=$(echo "$PAYLOAD" | jq -r '.effort.level // empty')

# Extract Git Branch (looking across all schemas)
GIT_BRANCH=$(echo "$PAYLOAD" | jq -r '
  .workspace.branch //
  .workspace.git_branch //
  ""
' 2>/dev/null)

CWD=$(echo "$PAYLOAD" | jq -r '
  .workspace.cwd //
  .workspace.path //
  ""
' 2>/dev/null)

# Fall back to raw pwd command if payload doesn't contain it
if [ -z "$CWD" ] || [ "$CWD" = "null" ]; then
  CWD=$(pwd)
fi

# Clean up / shorten the directory path for visual display:
# Swap user home dir for "~"
CWD="${CWD/#$HOME/\~}"

# If the path is too long (e.g. > 30 chars), truncate the middle so it fits nicely
if [ ${#CWD} -gt 30 ]; then
  CWD="…/${CWD##*/}"
fi

# If the payload lacks Git information, fall back to checking Git locally
if [ -z "$GIT_BRANCH" ] || [ "$GIT_BRANCH" = "null" ]; then
  GIT_BRANCH=$(git branch --show-current 2>/dev/null)
fi

# Parse and normalize context window usage
CTX_PCT=$(echo "$PAYLOAD" | jq -r '
  if .context_window.used_percentage != null then
    .context_window.used_percentage
  elif .context.used_percentage != null then
    .context.used_percentage
  elif .context_window.remaining_fraction != null then
    ((1.0 - (.context_window.remaining_fraction | tonumber)) * 100)
  else
    0
  fi
' 2>/dev/null)

# Handle float decimals safely in Bash
CTX_PCT_INT=$(printf "%.0f" "$CTX_PCT" 2>/dev/null || echo "0")

# Format a clean context window progress bar
# 10 character progress bar (1 block per 10%)
BAR_FILLED=$((CTX_PCT_INT / 10))
BAR_EMPTY=$((10 - BAR_FILLED))

# Set progress bar color based on usage thresholds
if [ "$CTX_PCT_INT" -lt 50 ]; then
  COLOR_BAR="\033[32m" # Green
elif [ "$CTX_PCT_INT" -lt 80 ]; then
  COLOR_BAR="\033[33m" # Yellow
else
  COLOR_BAR="\033[31m" # Red (Context warning)
fi

PROGRESS_BAR=""
for ((i = 0; i < BAR_FILLED; i++)); do PROGRESS_BAR="${PROGRESS_BAR}█"; done
for ((i = 0; i < BAR_EMPTY; i++)); do PROGRESS_BAR="${PROGRESS_BAR}░"; done

# Color Codes
COLOR_RESET="\033[0m"
COLOR_TAG="\033[1;36m"  # Cyan bold
COLOR_BRANCH="\033[35m" # Magenta

printf "${COLOR_TAG}%s${COLOR_RESET} | 󰿗 ${COLOR_TAG}%s${COLOR_RESET} |  ${COLOR_BAR}%s${COLOR_RESET}\n" \
  "$MODEL_NAME" "$EFFORT" "$PROGRESS_BAR"

if [ -n "$GIT_BRANCH" ]; then
  printf "󰉋 %s |  ${COLOR_BRANCH}%s${COLOR_RESET}" "$GIT_BRANCH" "$CWD"
else
  printf "󰉋 %s" "$CWD"
fi
