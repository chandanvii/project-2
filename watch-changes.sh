#!/bin/bash

echo "🔄 Starting local file watcher..."

while true; do
    if [ -n "$(git status --porcelain)" ]; then
        echo "📝 Changes detected, pushing to GitHub..."
        git add .
        git commit -m "Auto-commit: Local changes at $(date '+%Y-%m-%d %H:%M:%S')"
        git push origin main
        echo "✅ Changes pushed successfully!"
    fi
    sleep 30
done
