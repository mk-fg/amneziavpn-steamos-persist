# AmneziaVPN SteamOS reinstall hack

Hack to reinstall [AmneziaVPN app] and systemd service (via [Arch AUR package])
on [Steam Deck device] after any SteamOS updates, which normally flush any such
extra packages when replacing /usr and /opt dirs.

Allows to enable full AmneziaVPN in default Steam and Desktop modes easily,
intended to simplify day-to-day use at the expense of a bit more complicated
initial/up-front setup.

Don't own a Steam Deck myself, so no idea if it's still working or even relevant.

[AmneziaVPN app]: https://amnezia.org/
[Arch AUR package]: https://aur.archlinux.org/packages/amneziavpn-bin
[Steam Deck device]: https://store.steampowered.com/steamdeck

Sections below:

- [General idea](#hdr-general_idea)
- [Install](#hdr-install)
- [Quirks](#hdr-quirks)
- [Links](#hdr-links)

URLs for this repository:

- <https://github.com/mk-fg/amneziavpn-steamos-persist>
- <https://codeberg.org/mk-fg/amneziavpn-steamos-persist>
- <https://fraggod.net/code/git/amneziavpn-steamos-persist>


<a name=hdr-general_idea></a>
## General idea

Setup consists of following components:

- Under ~deck/amneziawg-vpn: (should probably be renamed to ~deck/amneziavpn)

    - `amneziavpn-bin-*-x86_64.pkg.tar.zst` - AUR package, easy to build,
      needs no extra dependencies on SteamOS.

        Built from: https://aur.archlinux.org/packages/amneziavpn-bin

        Installs /usr/bin/AmneziaVPN wrapper for official GUI app binary in /opt,
        and systemd service file to /usr/lib/systemd/system (which is also in /opt itself).

        Any package version will do, `amneziavpn-run.sh` picks latest one next to it via `sort -V`.\
        It bundles GUI libs, so should likely work on wide range of SteamOS releases.

    - `amneziavpn-run.sh` - wrapper script for AmneziaVPN from amneziavpn-bin
      package, installing that package when needed, like after SteamOS updates
      or reflash/recovery.

    - `amneziavpn-run.png` - icon for `amneziavpn-run.desktop`, should be
      copied from /usr/share/icons installed by amneziavpn-bin package or such
      (check `pacman -Ql amneziavpn-bin | grep /icons`), so that it's there even
      when package is not (and needs to be reinstalled).

- `~deck/Desktop/amneziavpn-run.desktop` - desktop entry/shortcut
  to run `amneziavpn-run.sh` wrapper.

- In Steam itself - `Add Existing Game...` with path = `"AmneziaVPN"` (desktop entry)
  and command-line = `env -u LD_PRELOAD %command%`, whatever defaults for rest.

    Command tweak suggested in [github amnezia-vpn/amnezia-client issue-1187],
    not sure if actually needed, copied from there just in case.

Testing - run `curl ifconfig.me` from `ssh deck@...` shell, after enabling/disabling
VPN in desktop or steam mode, should show IP changes between runs due to tunneling.

[github amnezia-vpn/amnezia-client issue-1187]:
  https://github.com/amnezia-vpn/amnezia-client/issues/1187


<a name=hdr-install></a>
## Install

- Build `amneziavpn-bin-*-x86_64.pkg.tar.zst` from [amneziavpn-bin on AUR],
  e.g. via usual git-clone + makepkg.

- Copy files over to Steam Deck device:


    ```
    dst=deck@10.x.y.z
    scp amneziavpn-run.sh amneziavpn-bin-*-x86_64.pkg.tar.zst $dst:amneziawg-vpn/
    scp amneziavpn-run.desktop $dst:Desktop/
    ```

- Run the app in Desktop mode, via "AmneziaVPN" icon (added by `amneziavpn-run.desktop`),
  test that it works (e.g. via `curl ifconfig.me` in ssh shell or terminal).

- Copy /usr/share/icons file from installed amneziavpn-bin pkg to
  `~deck/amneziawg-vpn/amneziavpn-run.png`, so that it looks nicely on the desktop.

- Add game/app to Steam for that .desktop entry, to run it in full-screen Steam mode via that.

Initially tested with `amneziavpn-bin-5.1.0.6-1-x86_64.pkg.tar.zst`

To remove it all anytime:
```
sudo sh -c 'steamos-readonly disable && { pacman --noconfirm -R amneziavpn-bin; steamos-readonly enable; }'
rm -rf ~/amneziawg-vpn ~/Desktop/amneziavpn-run.desktop ~/.config/AmneziaVPN.ORG
```
(last ~/.config/AmneziaVPN.ORG dir is where AmneziaVPN app keeps its settings and keys)

To update AmneziaVPN app, remove amneziavpn-bin package (first sudo-command above),
and put newer one into ~deck/amneziawg-vpn dir, for script to auto-install on next run.

[amneziavpn-bin on AUR]: https://aur.archlinux.org/packages/amneziavpn-bin


<a name=hdr-quirks></a>
## Quirks

- Running AmneziaVPN in Steam mode, it shows "Connect" button even if underlying
  amnezia systemd service have tunnel enabled/connected already.

    Doesn't seem to be a big deal, just need to do Connect-Disconnect to actually
    disconnect, can avoid closing the app for it to remember that state properly.

- Hard to quit AmneziaVPN in Steam mode - no "close" button, no "exit" in the app.

    Workaround - press Steam button, which allows to run any other games in
    parallel, or force-close the app easily. Not closing it is probably fine too.

- AmneziaVPN app can run with different locale or other such settings in Steam mode.

    Probably because of language settings in Steam itself, can add LANG= to
    `amneziavpn-run.sh` or command-line in Steam game entry as a workaround,
    if needed.

- Updates aren't really handled/supported by the script.

    Can add package version check to `amneziavpn-run.sh` vs latest package in
    the dir, and install/update as-needed.

    For more hands-off process, polling of some censorshit-resistant URL
    (e.g. on github or somesuch popular silo) can be used to auto-download
    new Arch package, if exists or is indicated there somehow.

- Not sure how [zenity] prompts will work in Steam mode if install is needed,
  haven't tested that at all.

    Workaround is to run the thing in Desktop mode once after update - works there for sure.

- zenity prompt for sudo password should probably be replaced by systemd-askpass
  or whatever KDE sudo wrapper or prompting mechanism that's installed on SteamOS.

    Copied zenity + sudo hack from [decky user_install_script.sh] though,
    which might be a well-tested time-proven solution.

- `~deck/amneziawg-vpn` dir name is misleading, was picked somewhat arbitrarily,
  and should be renamed to `~deck/amneziavpn` or such.

[zenity]: https://gitlab.gnome.org/GNOME/zenity
[decky user_install_script.sh]:
  https://github.com/SteamDeckHomebrew/decky-installer/blob/main/gui/user_install_script.sh


<a name=hdr-links></a>
## Links

- [amneziawg-deck] - [decky] plugin to have an easy toggle for
  wireguard-only Amnezia VPN in Steam mode "Quick Menu" ("..." key).

    Can only be toggled in fullscreen Steam mode, uses wireguard/awg config
    (no [XRay]) exported from AmneziaVPN app, won't work with [Free tier],
    but might be easier to use if you don't care about Desktop mode.

    Needs to be updated with recent awg / awg-quick / amneziawg-go binaries -
    run `./scripts/build_bin.sh`, replace "bin" dir in AmneziaWG.zip plugin release,
    copy updated zip file over and install from it.

- [amneziavpn-bin Arch Linux AUR package] - SteamOS is based on Arch,
  so works there as-is, with caveats of `steamos-readonly` and updates wiping it out.

- [aur-setup-for-steamdeck] - kinda similar ad-hoc solution to wrapper script here,
  to setup AUR helper and whatever packages via script from scratch or after SteamOS updates.
  Note that using arbitrary stuff from AUR, esp. as pulled-in by helpers [is a Bad Idea].

[amneziawg-deck]: https://github.com/basuev/amneziawg-deck
[decky]: https://decky.xyz/
[XRay]: https://docs.amnezia.org/documentation/xray/
[Free tier]: https://amnezia.org/free
[amneziavpn-bin Arch Linux AUR package]:
  https://aur.archlinux.org/packages/amneziavpn-bin
[aur-setup-for-steamdeck]:
  https://github.com/xatusbetazx17/aur-setup-for-steamdeck
[is a Bad Idea]: https://wiki.archlinux.org/title/AUR_helpers
