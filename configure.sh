#!/bin/bash

echo "Copying bash config..."
cp ./.bashrc ~/
source ~/.bashrc

echo "Copying tmux config..."
cp ./.tmux.conf ~/
tmux source-file ~/.tmux.conf > /dev/null 2>&1

echo "Copying Hyprland config..."
cp -r ./mako/ ./cava/ ./hypr/ ./waybar/ ~/.config/
hyprctl reload > /dev/null 2>&1
makoctl reload > /dev/null 2>&1
pkill cava > /dev/null 2>&1
pkill cava.sh > /dev/null 2>&1
pkill waybar > /dev/null 2>&1
hyprctl dispatch exec waybar > /dev/null 2>&1

echo "Copying nvim config..."
cp -r ./nvim/ ~/.config/
echo "Opening nvim..."
nvim
