#!/bin/bash
# Dell XPS touchpad fix for Pop!_OS / Ubuntu
# Reference: https://www.dell.com/support/kbdoc/en-ca/000150104/precision-xps-ubuntu-general-touchpad-mouse-issue-fix

set -e

echo "Creating touchpad configuration..."

# 1. Disable PS/2 Generic Mouse to prevent conflicts
cat > /etc/X11/xorg.conf.d/99-disable-ps2-mouse.conf << 'EOF'
# Disable PS/2 Generic Mouse to prevent touchpad conflicts
# Reference: https://www.dell.com/support/kbdoc/en-ca/000150104/precision-xps-ubuntu-general-touchpad-mouse-issue-fix
Section "InputClass"
    Identifier "Disable PS/2 Generic Mouse"
    MatchProduct "PS/2 Generic Mouse"
    MatchDevicePath "/dev/input/event*"
    Option "Ignore" "on"
EndSection
EOF
echo "Created /etc/X11/xorg.conf.d/99-disable-ps2-mouse.conf"

# 2. Disable DLL0945 Mouse duplicate (touchpad registering as both Mouse and Touchpad)
cat > /etc/X11/xorg.conf.d/99-disable-dll-mouse-duplicate.conf << 'EOF'
# Disable DLL0945 Mouse duplicate device
# The touchpad hardware registers as both Mouse and Touchpad, causing conflicts
# Reference: https://www.dell.com/support/kbdoc/en-ca/000150104/precision-xps-ubuntu-general-touchpad-mouse-issue-fix
Section "InputClass"
    Identifier "Disable DLL0945 Mouse duplicate"
    MatchProduct "DLL0945:00 04F3:311C Mouse"
    MatchDevicePath "/dev/input/event*"
    Option "Ignore" "on"
EndSection
EOF
echo "Created /etc/X11/xorg.conf.d/99-disable-dll-mouse-duplicate.conf"

# 3. Add Dell-recommended libinput touchpad options
cat > /etc/X11/xorg.conf.d/99-libinput-touchpad.conf << 'EOF'
# Dell-recommended libinput touchpad settings
# Reference: https://www.dell.com/support/kbdoc/en-ca/000150104/precision-xps-ubuntu-general-touchpad-mouse-issue-fix
Section "InputClass"
    Identifier "Dell touchpad settings"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "True"
    Option "TappingDrag" "True"
    Option "DisableWhileTyping" "True"
    Option "AccelProfile" "adaptive"
    Option "AccelSpeed" "0.4"
    Option "SendEventsMode" "disabled-on-external-mouse"
EndSection
EOF
echo "Created /etc/X11/xorg.conf.d/99-libinput-touchpad.conf"

echo ""
echo "Done. Reboot to apply changes."
