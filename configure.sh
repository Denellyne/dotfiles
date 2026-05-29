#!/bin/sh

echo "Copying bash config..."
cp ./.bashrc ~/

echo "Copying tmux config..."
cp ./.tmux.conf ~/

echo "Copying Hyprland config..."
cp -r ./hypr/ ./waybar/ ~/.config/
hyprctl reload

echo "Copying nvim config..."
cp -r ./nvim/ ~/.config/
echo "Opening nvim..."
nvim
