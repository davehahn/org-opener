#!/bin/bash

# Salesforce Org Opener - Installation Script
# Automates the complete setup on macOS

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Salesforce Org Opener - Installer    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
INSTALL_PATH="/usr/local/bin/openSF.sh"
SERVICE_NAME="Open a Salesforce Org"
SERVICE_PATH="$HOME/Library/Services/${SERVICE_NAME}.workflow"

# Step 1: Install the bash script
echo -e "${YELLOW}[1/4]${NC} Checking dependencies..."

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq is not installed${NC}"
    echo ""
    
    # Check if Homebrew is installed
    if command -v brew &> /dev/null; then
        echo -e "${BLUE}Homebrew is installed.${NC}"
        read -p "Would you like to install jq now? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo -e "${BLUE}Installing jq...${NC}"
            brew install jq
            if command -v jq &> /dev/null; then
                echo -e "${GREEN}✓ jq installed successfully${NC}"
            else
                echo -e "${RED}Error: jq installation failed${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Installation cancelled. jq is required to run this tool.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Homebrew is not installed.${NC}"
        echo ""
        echo -e "${BLUE}Homebrew is a package manager for macOS that makes installing${NC}"
        echo -e "${BLUE}tools like jq easy. To install Homebrew, visit:${NC}"
        echo -e "${GREEN}  https://brew.sh${NC}"
        echo ""
        echo -e "${BLUE}Or run this command in your terminal:${NC}"
        echo -e "${GREEN}  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
        echo ""
        echo -e "${YELLOW}After installing Homebrew, please run this installer again.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ jq is installed${NC}"
fi

# Check for Salesforce CLI
if ! command -v sf &> /dev/null && ! command -v sfdx &> /dev/null; then
    echo -e "${YELLOW}⚠ Salesforce CLI (sf) is not installed${NC}"
    echo -e "  Install from: ${GREEN}https://developer.salesforce.com/tools/sfcli${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Salesforce CLI is installed${NC}"
fi

echo ""

# Step 2: Install the bash script
echo -e "${YELLOW}[2/4]${NC} Installing openSF.sh to /usr/local/bin..."

if [ ! -f "$SCRIPT_DIR/scripts/openSF.sh" ]; then
    echo -e "${RED}Error: scripts/openSF.sh not found${NC}"
    echo -e "${RED}Please run this script from the org-opener directory${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/scripts/appleScriptCode" ]; then
    echo -e "${RED}Error: scripts/appleScriptCode not found${NC}"
    echo -e "${RED}Please run this script from the org-opener directory${NC}"
    exit 1
fi

# Create /usr/local/bin if it doesn't exist
if [ ! -d "/usr/local/bin" ]; then
    echo "Creating /usr/local/bin directory..."
    sudo mkdir -p /usr/local/bin
fi

# Copy and make executable
sudo cp "$SCRIPT_DIR/scripts/openSF.sh" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

echo -e "${GREEN}✓ openSF.sh installed successfully${NC}"
echo ""

# Step 3: Create Automator Quick Action
echo -e "${YELLOW}[3/4]${NC} Creating Automator Quick Action..."

# Read the AppleScript code from file
APPLESCRIPT_CODE=$(cat "$SCRIPT_DIR/scripts/appleScriptCode")

# Create the Services directory if it doesn't exist
mkdir -p "$HOME/Library/Services"

# Create the workflow bundle structure
mkdir -p "${SERVICE_PATH}/Contents"

# Create Info.plist
cat > "${SERVICE_PATH}/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleIdentifier</key>
	<string>com.apple.automator.Open a Salesforce Org</string>
	<key>CFBundleName</key>
	<string>Open a Salesforce Org</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Open a Salesforce Org</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
		</dict>
	</array>
</dict>
</plist>
EOF

# Create document.wflow with embedded AppleScript
cat > "${SERVICE_PATH}/Contents/document.wflow" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>523</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.applescript.object</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>1.0.2</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.applescript.object</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run AppleScript.action</string>
				<key>ActionName</key>
				<string>Run AppleScript</string>
				<key>ActionParameters</key>
				<dict>
					<key>source</key>
					<string>${APPLESCRIPT_CODE}</string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.Automator.RunScript</string>
				<key>CFBundleVersion</key>
				<string>1.0.2</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunScriptAction</string>
				<key>InputUUID</key>
				<string>AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE</string>
				<key>Keywords</key>
				<array>
					<string>Run</string>
				</array>
				<key>OutputUUID</key>
				<string>FFFFFFFF-GGGG-HHHH-IIII-JJJJJJJJJJJJ</string>
				<key>UUID</key>
				<string>AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<string>on run {input, parameters}
	
	(* Your script goes here *)
	
	return input
end run</string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<integer>1</integer>
				<key>location</key>
				<string>449.000000:316.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run AppleScript.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<integer>1</integer>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Quick Action created successfully${NC}"
echo ""

# Step 4: Instructions for keyboard shortcut
echo -e "${YELLOW}[4/4]${NC} Keyboard Shortcut Setup"
echo ""
echo -e "${BLUE}To add a keyboard shortcut:${NC}"
echo -e "  1. Open ${YELLOW}System Settings${NC} > ${YELLOW}Keyboard${NC} > ${YELLOW}Keyboard Shortcuts${NC}"
echo -e "  2. Select ${YELLOW}Services${NC} in the left sidebar"
echo -e "  3. Scroll down to find ${YELLOW}'Open a Salesforce Org'${NC}"
echo -e "  4. Click ${YELLOW}'Add Shortcut'${NC} and press your desired key combination"
echo -e "     ${GREEN}Recommended: ⌘⇧O (Command + Shift + O)${NC}"
echo ""

# Optional: Attempt to reload services
echo -e "${YELLOW}Reloading services...${NC}"
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall cfprefsd 2>/dev/null || true

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     Installation Complete! 🎉         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo -e "  ${GREEN}Command Line:${NC}  ${YELLOW}openSF.sh${NC}"
echo -e "  ${GREEN}Quick Action:${NC}  Press your keyboard shortcut or use Services menu"
echo ""
echo -e "${BLUE}The script will:${NC}"
echo -e "  • Display a menu of your authorized Salesforce orgs"
echo -e "  • Allow you to select which org to open"
echo -e "  • Open the org in your default browser"
echo -e "  • Automatically close the Terminal window when done"
echo ""
echo -e "${GREEN}Note:${NC} You may need to log out and back in for the Quick Action to appear."
echo ""

