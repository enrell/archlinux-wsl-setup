#!/bin/bash

echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
echo -n "Enter your username: " && read username
useradd -m -G wheel -s /bin/bash $username
passwd $username
