#!/bin/bash
# save as watch-changes.sh

# Colors for better visibility
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_PATH=$(pwd)
BRANCH="main"
DOCKER_IMAGE="chandanviii/project-2"
CONTAINER_NAME="finexo-container"

echo -e "${BLUE}🔄 Starting automated file watcher...${NC}"
echo -e "${BLUE}📂 Watching directory: ${REPO_PATH}${NC}"

# Function to handle Docker operations
update_docker() {
    echo -e "${GREEN}🐳 Updating Docker container...${NC}"
    docker pull $DOCKER_IMAGE:latest
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
    docker run -d -p 8083:80 --name $CONTAINER_NAME $DOCKER_IMAGE:latest
}

# Function to handle Git operations
handle_changes() {
    echo -e "${GREEN}📝 Changes detected! Processing...${NC}"
    
    # Add all changes
    git add .
    
    # Get list of changed files
    changed_files=$(git status --porcelain)
    
    if [ -n "$changed_files" ]; then
        # Create detailed commit message
        commit_message="Auto-commit: Changes detected\n\nModified files:\n${changed_files}"
        
        # Commit changes
        git commit -m "$(echo -e $commit_message)"
        
        # Push changes
        if git push origin $BRANCH; then
            echo -e "${GREEN}✅ Changes pushed successfully!${NC}"
            
            # Update Docker container
            update_docker
            
            echo -e "${GREEN}🌐 Website is live at: http://localhost:8083${NC}"
        else
            echo -e "${RED}❌ Failed to push changes${NC}"
        fi
    fi
}

# Function to check if file is ignored by git
is_ignored() {
    git check-ignore "$1" > /dev/null 2>&1
}

# Set up inotifywait
if ! command -v inotifywait &> /dev/null; then
    echo "Installing inotify-tools..."
    sudo apt-get update && sudo apt-get install -y inotify-tools
fi

# Main watch loop
echo -e "${GREEN}👀 Watching for changes...${NC}"

inotifywait -m -r -e modify,create,delete,move --format '%w%f' "$REPO_PATH" | while read FILE
do
    # Ignore .git directory and temporary files
    if [[ $FILE != *".git"* ]] && ! is_ignored "$FILE"; then
        handle_changes
    fi
done
