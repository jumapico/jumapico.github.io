#!/bin/bash
set -e
TOMBSIZE=512
TOMBFILE="$HOME/graveyard/browsers.tomb"
KEYFILE="$HOME/browsers.tomb.key"
MOUNTPOINT="/run/media/$USER/browsers"

# Fail if needed commands can't be found
ensure_needed_commands() {
    # Ensure needes commands are installed
    which tomb >& /dev/null \
        || { echo "tomb not installed" >&2; exit 1; }
    which pinentry-curses >& /dev/null \
        || { echo "pinentry-curses not installed" >&2; exit 1; }
    which gio >& /dev/null \
        || { echo "gio not installed (libglib2.0-bin)" >&2; exit 1; }
    which gsettings >& /dev/null \
        || { echo "gsettings not installed (libglib2.0-bin)" >&2; exit 1; }
}

# Create and configure tomb file if not exist
ensure_tomb_file() {
    echo "Creating tomb file and key..."
    if [ -e "$TOMBFILE" ] && [ -e "$KEYFILE" ]; then
        echo 'skip: tomb file and key already exists'
        if ! tomb list browsers >& /dev/null; then
            tomb open -f -k "$KEYFILE" "$TOMBFILE" "$MOUNTPOINT"
        fi
    elif [ -e "$TOMBFILE" ]; then
        echo "abort: tomb key doesn't exists, remove tomb file and try again:"
        echo "\trm \"$TOMBFILE\""
        exit 1
    elif [ -e "$KEYFILE" ]; then
        echo "abort: tomb key without tomb file, remove tomb key and try again:"
        echo "\trm \"$KEYFILE\""
        exit 1
    else
        mkdir -p "$(dirname "$TOMBFILE")" "$(dirname "$KEYFILE")"
        tomb dig -s $TOMBSIZE "$TOMBFILE"
        tomb forge -f "$KEYFILE"
        tomb lock -k "$KEYFILE" "$TOMBFILE"
        echo "done"
        tomb open -f -k "$KEYFILE" "$TOMBFILE" "$MOUNTPOINT"
    fi
}

# Create and configure firefox mountpoint if not exist
configure_mountpoint() {
    echo "Configuring tomb bind-hooks..."
    mkdir -p "$HOME/.firefox-private"

    mkdir -p "$MOUNTPOINT/firefox-private"
    if [ ! -e "$MOUNTPOINT/bind-hooks" ] \
            || ! grep firefox-private "$MOUNTPOINT/bind-hooks"; then
        echo 'firefox-private .firefox-private' >> "$MOUNTPOINT/bind-hooks"
        tomb close browsers
        tomb open -f -k "$KEYFILE" "$TOMBFILE" "$MOUNTPOINT"
    fi
    echo "done"
}

# Move firefox current profile
migrate_profile() {
    echo "Migrating curreng firefox profile..."
    if [ ! -z "$(ls -A "$MOUNTPOINT/firefox-private" 2> /dev/null)" ]; then
        echo "skip: firefox-private not empty"
    elif [ -e "$HOME/.mozilla/firefox/profiles.ini" ]; then
        path="$(awk -F '=' '
/Default=1/ {d=1}
/Path=/ {cp=$2}
/^\[.*\]/ {if (d==1) {d=0; path=cp;}}
END {if(d==1) print cp; else print path}' \
        "$HOME/.mozilla/firefox/profiles.ini")"
        mv "$HOME/.mozilla/firefox/$path/"* "$MOUNTPOINT/firefox-private/"
        rm -fr "$HOME/.cache/mozilla/firefox/$path"
        echo "done"
    else
        echo "skip: Can't found profile to migrate"
        mkdir -p "$MOUNTPOINT/firefox-private"
    fi
}

create_scripts() {
    echo "Creating scripts..."
    # Create firefox-private script
    echo -n "~/bin/firefox-private "
    mkdir -p "$HOME/bin"
    cat > "$HOME/bin/firefox-private" <<'END'
#!/bin/bash
set -e
show_error() {
    if [[ $(readlink -f /proc/$(ps -o ppid:1= -p $$)/exe) = $(readlink -f "$SHELL") ]]; then
        echo -e "$1"
    elif [ -x /usr/bin/zenity ]; then
        zenity --warning --width=500 --text "$1"
    fi
}

if [ ! -d "$HOME/.firefox-private" ]; then
    show_error "Directory $HOME/.firefox-private don't exist\nCreate it and reopen tomb file\n"
    exit 1
elif ! mountpoint -q "$HOME/.firefox-private"; then
    show_error "Directory $HOME/.firefox-private is not a mount point\nTry open tomb file\n"
    exit 1
elif [ ! -d /opt/firefox-latest ]; then
    show_error "Missing firefox installation in \`/opt/firefox-latest\`\n"
    exit 1
fi
/opt/firefox-latest/firefox --profile "$HOME/.firefox-private" "$@"
END
    chmod +x "$HOME/bin/firefox-private"
    echo "done"

    # Create firefox-private application file
    echo -n "~/.local/share/applications/firefox-private.desktop "
    mkdir -p "$HOME/.local/share/applications"
    cat > "$HOME/.local/share/applications/firefox-private.desktop" <<'END'
[Desktop Entry]
Version=1.0
Name=Firefox private (latest)
GenericName=Web Browser
Comment=Browse the World Wide Web
Exec=bin/firefox-private %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox-latest/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=firefox-private
StartupNotify=true
END
    echo "done"
}

set_default_browser_with_keybinding() {
    local schema

    echo "Setting firefox-private as browser..."
    # Use firefox-private as default browser
    for mimetype in x-scheme-handler/http x-scheme-handler/https text/html; do
        gio mime $mimetype firefox-private.desktop || :
    done
    echo "done"

    echo "Setting keybindings for default browser..."
    # Add keybinding to default browser in mate desktop
    if gsettings get org.mate.SettingsDaemon.plugins.media-keys www \
            >& /dev/null; then
        gsettings set org.mate.SettingsDaemon.plugins.media-keys www \
            '<Primary><Alt>f'
        echo "done (mate)"
    fi
}

main() {
    ensure_needed_commands
    ensure_tomb_file
    configure_mountpoint
    migrate_profile
    create_scripts
    set_default_browser_with_keybinding
    echo "End"
    exit 0
}

main
