#!/bin/bash

# 0. Check for Firefox; install if missing
if ! command -v firefox &> /dev/null; then
    echo "Firefox is not installed. Installing Firefox..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y firefox
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y firefox
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm firefox
    else
        echo "Error: Unsupported package manager. Please install Firefox manually and re-run this script."
        exit 1
    fi
else
    echo "Firefox is already installed."
fi

# 1. Define base directories
FIREFOX_BASE="$HOME/.mozilla/firefox"
PROFILE_DIR="$HOME/.config/mozilla/whatsapp"

# 2. Locate the default profile path from profiles.ini
if [ -f "$FIREFOX_BASE/profiles.ini" ]; then
    DEFAULT_PROFILE=$(awk -F= '/^Path=/ {print $2; exit}' "$FIREFOX_BASE/profiles.ini")
fi

if [ -n "$DEFAULT_PROFILE" ] && [ -d "$FIREFOX_BASE/$DEFAULT_PROFILE" ]; then
    SOURCE_PROFILE="$FIREFOX_BASE/$DEFAULT_PROFILE"
    echo "Found default profile via profiles.ini: $SOURCE_PROFILE"
else
    echo "profiles.ini entry not found. Searching for a default-release profile..."
    SOURCE_PROFILE=$(find "$FIREFOX_BASE" -maxdepth 1 -type d -name "*.default-release" | head -n 1)
fi

# 3. Create target profile directory and copy existing profile contents
mkdir -p "$PROFILE_DIR"

if [ -d "$SOURCE_PROFILE" ] && [ "$SOURCE_PROFILE" != "$PROFILE_DIR" ]; then
    echo "Copying profile data from $SOURCE_PROFILE to $PROFILE_DIR..."
    cp -rT "$SOURCE_PROFILE" "$PROFILE_DIR"
    rm -f "$PROFILE_DIR/parent.lock" "$PROFILE_DIR/.parentlock"
else
    echo "Starting with a fresh profile or profile already in place."
fi

# 4. Create the chrome configuration directory inside the profile
mkdir -p "$PROFILE_DIR/chrome"

# 5. Configure preferences
cat << 'EOF' > "$PROFILE_DIR/user.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.tabs.inTitlebar", 0);
EOF

# 6. Add CSS to hide all internal toolbars
cat << 'EOF' > "$PROFILE_DIR/chrome/userChrome.css"
/* Hide the Navigation Bar (URL bar & navigation buttons) */
#nav-bar {
  visibility: collapse !important;
}

/* Hide the Bookmarks Toolbar */
#PersonalToolbar {
  visibility: collapse !important;
}

/* Hide the Tabs Toolbar */
#TabsToolbar {
  visibility: collapse !important;
}
EOF

# 7. Create the executable command in /usr/local/bin/whatsapp
echo "Creating /usr/local/bin/whatsapp command (requires sudo)..."
sudo bash -c "cat << 'EOF' > /usr/local/bin/whatsapp
#!/bin/bash
firefox -no-remote -profile \"$PROFILE_DIR\" \"https://web.whatsapp.com\" &
EOF
chmod +x /usr/local/bin/whatsapp"

# 8. Create a Desktop Shortcut (.desktop file)
DESKTOP_DIR="$HOME/Desktop"
[ -d "$HOME/xdg-desktop-dir" ] && DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
mkdir -p "$DESKTOP_DIR"

cat << EOF > "$DESKTOP_DIR/whatsapp.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=WhatsApp
Comment=WhatsApp Web Kiosk
Exec=whatsapp
Icon=whatsapp
Terminal=false
Categories=Network;Chat;
EOF

chmod +x "$DESKTOP_DIR/whatsapp.desktop"
which update-desktop-database &>/dev/null && update-desktop-database "$DESKTOP_DIR"

echo "Setup complete! You can now run 'whatsapp' from your terminal or click the WhatsApp icon on your desktop."
