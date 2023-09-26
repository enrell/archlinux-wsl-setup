#!/bin/bash

if ! grep -q wheel /etc/group; then
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
fi
echo -n "Enter your username: " && read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
