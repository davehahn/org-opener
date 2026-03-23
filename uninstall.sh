#!/bin/bash

# Salesforce Org Opener - Uninstallation Script
# Removes all installed components

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Salesforce Org Opener - Uninstaller  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

INSTALL_PATH="/usr/local/bin/openSF.sh"
SERVICE_NAME="Open Salesforce Org"
SERVICE_PATH="$HOME/Library/Services/${SERVICE_NAME}.workflow"

# Confirm uninstallation
echo -e "${YELLOW}This will remove:${NC}"
echo -e "  • ${INSTALL_PATH}"
echo -e "  • ${SERVICE_PATH}"
echo ""
read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstallation cancelled.${NC}"
    exit 0
fi

echo ""

# Remove bash script
if [ -f "$INSTALL_PATH" ]; then
    echo -e "${YELLOW}Removing openSF.sh...${NC}"
    sudo rm -f "$INSTALL_PATH"
    echo -e "${GREEN}✓ openSF.sh removed${NC}"
else
    echo -e "${YELLOW}⚠ openSF.sh not found (already removed?)${NC}"
fi

# Remove Quick Action
if [ -d "$SERVICE_PATH" ]; then
    echo -e "${YELLOW}Removing Quick Action...${NC}"
    rm -rf "$SERVICE_PATH"
    echo -e "${GREEN}✓ Quick Action removed${NC}"
else
    echo -e "${YELLOW}⚠ Quick Action not found (already removed?)${NC}"
fi

# Reload services
echo -e "${YELLOW}Reloading services...${NC}"
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall cfprefsd 2>/dev/null || true

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Uninstallation Complete! 👋         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Note:${NC} If you set a keyboard shortcut, you may want to remove it manually from:"
echo -e "      System Settings > Keyboard > Keyboard Shortcuts > Services"
echo ""
