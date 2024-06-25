#!/bin/sh
set -e

# Variables
PROGRAM_NAME="Evoland"
PROGRAM_URL="https://www.gog.com/game/evoland"
PROGRAM_PATH="GOG Games/Evoland/Evoland.exe"
INSTALLER_FILE="setup_evoland_1.1.2490_(20677).exe"
INSTALLER_CHECKSUM=a478ca738c312a6b8a2f289f309efa7c893efe3b06ff1753a6bea88864b62ce7
DIALOG_WIDTH=400

if [ ! -f "$WINEPREFIX/drive_c/$PROGRAM_PATH" ]; then
    # install
    XDG_DOWNLOAD_DIR="$(xdg-user-dir DOWNLOAD)"

    if [ ! -f "$XDG_DOWNLOAD_DIR/$INSTALLER_FILE" ]; then
        zenity --error --no-markup --width=$DIALOG_WIDTH --text="$(cat <<END
Can't found the file \`${INSTALLER_FILE}\`
in the *Downloads* directory.

Please, download it from <${PROGRAM_URL}>
and run again.
END
            )"
        exit 1
    fi

    if ! echo "$INSTALLER_CHECKSUM  $XDG_DOWNLOAD_DIR/$INSTALLER_FILE" | sha256sum -c --quiet; then
        zenity --error --no-markup --width=$DIALOG_WIDTH --text="$(cat <<END
The file \`${INSTALLER_FILE}\` in *Downloads* directory
has an unexpected sha256 sum.

Please, download it again from <${PROGRAM_URL}>
and check that the sha256sum of the file is
\`${INSTALLER_CHECKSUM}\` and run again.
END
            )"
        exit 1
    fi

    zenity --info --no-markup --width=$DIALOG_WIDTH --text="$(cat <<END
Running ${PROGRAM_NAME} installer.

* Only accept the EULA (don't change installation directory)
* Ignore error messages at the end of installation
* Exit the installer - Don't press Launch button!
END
        )"
    wine64 "$XDG_DOWNLOAD_DIR/$INSTALLER_FILE" '/LANG=English'
fi

# run program
wine64 "$WINEPREFIX/drive_c/$PROGRAM_PATH"
