#!/bin/bash
#
# Copyright (C) 2024 saadelasfur

VERIFY_7Z()
{
    if ! command -v 7z &> /dev/null; then
        echo "7z (7-Zip) is not installed. Installing it now..."
        
        if [ -x "$(command -v pkg)" ]; then
            pkg install -y p7zip
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get install -y p7zip-full
        elif [ -x "$(command -v yum)" ]; then
            sudo yum install -y p7zip
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y p7zip
        elif [ -x "$(command -v pacman)" ]; then
            sudo pacman -S --noconfirm p7zip
        else
            echo "Unsupported package manager. Please install 7z manually."
            exit 1
        fi
    else
        echo "7z (7-Zip) is already installed."
    fi
}

MAKE_ZIP()
{
    local SOURCE_DIR
    local OUTPUT_ZIP
    local INSTALLER_ZIP
    
    SOURCE_DIR=$1
    OUTPUT_ZIP="${SOURCE_DIR}-$(date +%Y%m%d).zip"
    INSTALLER_ZIP="Installers/Installer.zip"
    
    7z x "$INSTALLER_ZIP" -o"$SOURCE_DIR"
    cat "Installers/$SOURCE_DIR/updater-script" > "$SOURCE_DIR/META-INF/com/google/android/updater-script"
    cd "$SOURCE_DIR"
    find . -exec touch -a -c -m -d "2008-12-31 17:00:00 +0200" {} +
    7z a -tzip -mx=5 "$OUTPUT_ZIP" -x!"version" *
    mv -f "$OUTPUT_ZIP" "$HOME_DIR/$OUTPUT_ZIP"
    echo "$OUTPUT_ZIP has been moved to $HOME_DIR"
    rm -rf META-INF
    cd ..
}

echo ""
echo "Verifying 7z (7-Zip)..."
VERIFY_7Z

echo ""
echo "Making SmartManagerCN zip..."
MAKE_ZIP "SmartManagerCN"

echo ""
echo "Making StockDeviceCare zip..."
MAKE_ZIP "StockDeviceCare"

echo ""
echo "Build finished, exiting..."
sleep 3
exit 0
