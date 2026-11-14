#!/bin/bash
p=$(realpath "$0"); cd "${p%/*}"
set -o pipefail

## amneziavpn-bin should normally be installed already, unless removed by SteamOS updates

awg_bin=/usr/bin/AmneziaVPN
pacman --noconfirm -Qq amneziavpn-bin &>/dev/null && exec $awg_bin

## Reinstall latest amneziavpn-bin Arch package next to this script after updates/reflash

exec 2> >(grep -vaP '^(\(zenity:\d+\): (Gtk|Gdk|Adwaita)-\S+ |\s*$)' >&2)
gui() { zenity --title='AmneziaVPN SteamOS-update fix' "$@"; }

awg_pkg=$(ls -1 amneziavpn-bin-*.pkg.tar.zst 2>/dev/null | sort -V | tail -1)
[[ -n "$awg_pkg" ]] || {
	awg_pkg_dir='~/amneziawg-vpn' # nicer short dirname
	[[ "$PWD" = /home/deck/amneziawg-vpn ]] || awg_pkg_dir=$PWD
	gui --info --text="Missing $awg_pkg_dir/*.pkg.tar.zst package file(s)"
	exit 1; }

awg_pass=
while :; do
	awg_pass=$( gui --width=300 --height=100 \
		--entry --hide-text --text='Enter your deck/sudo password' )
	[[ $? -ne 1 && $? -ne 5 ]] || exit 1
	sudo -Sk true <<< "$awg_pass" && break
	gui --info --text='Incorrect password, try again'
done

set -e
sudo -S steamos-readonly disable <<< "$awg_pass"
sudo -S pacman --noconfirm -U "$awg_pkg" <<< "$awg_pass"
sudo -S steamos-readonly enable <<< "$awg_pass"
awg_pass=

exec $awg_bin
