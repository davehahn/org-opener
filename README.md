# Salesforce Org Opener 🚀

A macOS utility that simplifies opening Salesforce organizations in your browser using the Salesforce CLI. Features an interactive menu, system-wide Quick Action, and keyboard shortcut support with automatic Terminal cleanup.

## Features

- 🔥 **One-Command Installation** - Automated setup script handles everything
- ⌨️ **Keyboard Shortcut** - Access from anywhere with a custom shortcut
- 🖥️ **Terminal Integration** - Auto-closing terminal windows (no cleanup needed)
- 📋 **Interactive Menu** - Select from all your authorized Salesforce orgs
- 🎯 **Quick Action** - Available in macOS Services menu
- 🔐 **Secure** - Uses Salesforce CLI authentication (no password storage)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/org-opener.git
cd org-opener

# Run the installer
chmod +x install.sh
./install.sh
```

That's it! The installer will:
1. ✅ Check for required dependencies (Salesforce CLI & jq)
2. ✅ Copy `openSF.sh` to `/usr/local/bin`
3. ✅ Create the "Open Salesforce Org" Quick Action
4. ✅ Make it available in your Services menu

## Prerequisites

- **Salesforce CLI** ([sf](https://developer.salesforce.com/tools/sfcli)) - Required for org management
- **jq** - JSON processor for parsing org data
  ```bash
  brew install jq
  ```

## Usage

### Command Line

Simply run:
```bash
openSF.sh
```

The script will:
1. Display a menu of all your authorized Salesforce orgs
2. Let you select which org to open
3. Open the selected org in your default browser
4. Provide options to refresh the list, authorize new orgs, or remove orgs

**Menu Options:**
- Select a number to open that org
- `q` - Quit
- `r` - Refresh org list
- `a` - Authorize a new org
- `d` - Remove an org

### Quick Action with Keyboard Shortcut

**Set up your keyboard shortcut (one-time setup):**

1. Open **System Settings** → **Keyboard** → **Keyboard Shortcuts**
2. Select **Services** in the left sidebar
3. Scroll to find **"Open Salesforce Org"**
4. Click **Add Shortcut** and press your desired combination
   - Recommended: `⌘⇧O` (Command + Shift + O)

**Using the Quick Action:**

Press your keyboard shortcut from anywhere, and the script will:
- Open Terminal and display the org selection menu
- Wait for you to select an org
- Open the org in your browser
- Automatically close the Terminal window when complete

## How It Works

### The Bash Script (`openSF.sh`)

The script uses the Salesforce CLI to:
- Fetch and cache your list of authorized orgs (both scratch and non-scratch)
- Display an interactive menu using `select`
- Open the selected org using `sf org open`
- Manage org authorization and removal

**Key Features:**
- Caches org list in `sandboxes.json` for faster subsequent runs
- Validates dependencies before running
- Color-coded output for better readability
- Handles both scratch orgs and regular orgs

### The AppleScript (via Automator)

Handles Terminal lifecycle management to provide a seamless experience:

```applescript
tell application "Terminal"
    set T to do script "bash /usr/local/bin/openSF.sh"
    activate
    set w to the id of window 1 where its tab 1 = T
    repeat
        delay 0.5
        if not busy of T then exit repeat
    end repeat
    close window id w
end tell
```

This ensures:
- Terminal opens and runs the script
- Waits for you to make your selection
- Waits for script completion
- Automatically closes the Terminal window
- No leftover Terminal windows cluttering your desktop

## Project Structure

```
org-opener/
├── scripts/
│   ├── openSF.sh           # Main Salesforce org opener script
│   └── appleScriptCode     # AppleScript for Automator workflow
├── install.sh              # Automated installer
├── uninstall.sh            # Clean removal script
├── README.md               # This file
├── LICENSE                 # MIT License
└── .gitignore              # Git ignore patterns
```

## First Time Setup

After installation, you'll need to authorize at least one Salesforce org:

```bash
# Authorize a production org
sf org login web --instance-url https://login.salesforce.com --alias my-prod

# Authorize a sandbox
sf org login web --instance-url https://test.salesforce.com --alias my-sandbox
```

Or use the interactive prompt in the script by selecting option `a` (Authorize new org).

## Configuration

### Org Aliases

When authorizing orgs, use meaningful aliases:

```bash
sf org login web --instance-url https://login.salesforce.com --alias prod
sf org login web --instance-url https://test.salesforce.com --alias dev-sandbox
sf org login web --instance-url https://test.salesforce.com --alias qa-sandbox
```

These aliases will appear in the menu for easy selection.

### Cached Org List

The script caches your org list in `sandboxes.json` in the same directory where you run it. To manually refresh this list:

- Use option `r` in the menu
- Or delete the `sandboxes.json` file

## Uninstallation

```bash
chmod +x uninstall.sh
./uninstall.sh
```

This removes:
- `/usr/local/bin/openSF.sh`
- `~/Library/Services/Open Salesforce Org.workflow`

**Note:** Keyboard shortcuts are not automatically removed. Remove them manually from:  
System Settings > Keyboard > Keyboard Shortcuts > Services

## Troubleshooting

### Quick Action doesn't appear

1. Log out and log back in
2. Try manually running: `/System/Library/CoreServices/pbs -flush`
3. Check that the workflow exists: `ls ~/Library/Services/`

### "jq is not installed" error

```bash
brew install jq
```

### "sf cli is not installed" error

Install the Salesforce CLI from: https://developer.salesforce.com/tools/sfcli

### No orgs appear in the menu

1. Authorize at least one org:
   ```bash
   sf org login web --instance-url https://login.salesforce.com --alias my-org
   ```
2. Or use option `a` in the script menu

### Terminal window doesn't close

The AppleScript waits for the script to complete. If the Terminal stays open:
- Make sure you've made a selection from the menu (don't leave it hanging)
- Check if the script encountered an error
- Verify `/usr/local/bin/openSF.sh` is executable: `ls -l /usr/local/bin/openSF.sh`

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit your changes: `git commit -am 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Dave** - Built for Salesforce admins and developers who manage multiple orgs and value efficiency.

## Acknowledgments

- Uses the excellent [Salesforce CLI](https://developer.salesforce.com/tools/sfcli)
- Built with ❤️ for the Salesforce community
- Inspired by the daily workflow of managing multiple Salesforce orgs

---

⭐ **Star this repo** if it saves you time!

💡 **Have ideas?** Open an issue or PR!
