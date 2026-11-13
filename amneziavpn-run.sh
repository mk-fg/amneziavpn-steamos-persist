#!/bin/bash
p=$(realpath "$0"); cd "${p%/*}"

pacman --noconfirm -Qq amneziavpn-bin &>/dev/null && exec /usr/bin/AmneziaVPN

# Reinstall latest amneziavpn-bin Arch package next to this script after SteamOS update(s)
win() { zenity 2> >(grep -v 'Gtk' >&2) --title='AmneziaVPN post SteamOS update fix' "$@"; }

awg_pkg=$(ls -1 amneziavpn-bin-*.pkg.tar.zst 2>/dev/null | sort -V | tail -1)
[[ -n "$awg_pkg" ]] || {
	awg_pkg_dir='~/amneziawg-vpn'
	[[ "$PWD" = /home/deck/amneziawg-vpn ]] || awg_pkg_dir=$PWD
	win --info --text="Missing $awg_pkg_dir/*.pkg.tar.zst package file(s)"
	exit 1; }

awg_pass= awg_done=
while [[ -z "$awg_done" ]]; do
	awg_pass=$( win \
		--width=300 --height=100 --entry --hide-text --text="Enter your deck/sudo password" )
	if [[ $? -eq 1 ]] || [[ $? -eq 5 ]]; then exit 1; fi
	if ( echo "$awg_pass" | sudo -S -k true ); then awg_done=1; break; fi
	win --info --text="Incorrect password, try again"
done

set -eo pipefail
echo "$awg_pass" | sudo -E -S -k steamos-readonly disable
echo "$awg_pass" | sudo -E -S -k pacman --noconfirm -U "$awg_pkg"
echo "$awg_pass" | sudo -E -S -k steamos-readonly enable
awg_pass=

exec /usr/bin/AmneziaVPN
