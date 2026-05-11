#!/bin/bash

# PPD Diary - Minimal Control Panel
PINK='\033[38;5;206m'
NC='\033[0m'

echo -e "${PINK}"
echo "  🌸 ========================================== 🌸"
echo "         POSTPARTUM DIARY - COMPACT VERSION"
echo "  🌸 ========================================== 🌸"
echo -e "${NC}"

# Start the consolidated Flask app via Gunicorn
gunicorn --workers 1 --bind 0.0.0.0:8000 app:app
