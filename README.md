# MacTuck

MacTuck folds the menu bar of the app you are using into a single
`AppName ▾` pill. Click the pill and you get a dropdown that mirrors the app's
real menus: every submenu, keyboard shortcut, check mark and disabled item,
read live, and choosing an item triggers the real one.

```
Before:   Xcode  File  Edit  View  Navigate  Editor  Product  Debug  Window  Help
After:   Xcode ▾
```

No status item, no Dock icon, no network. One permission: Accessibility.

## What it does, honestly

macOS draws the menu bar of whichever app is frontmost, and no API, public or
private, lets another process remove or shrink that app's menu titles. MacTuck
therefore draws a floating strip over the titles. The strip hides them and
hosts the pill, but the titles still exist underneath, so this does not free
menu bar space for status icons. If your problem is icons being pushed out of
the bar, a menu bar manager such as Ice is the tool for that.

What MacTuck gives you is a calm bar and one compact, searchable-by-eye entry
point to every menu of the current app.

## Requirements

- macOS 14 or later. Built and tested on macOS 26 with an Apple silicon Mac.
- Xcode 16 or later, or the Command Line Tools, for the Swift 6 toolchain.

## Install

MacTuck is built from source with Swift Package Manager. There is no Xcode
project and no binary download.

```sh
git clone https://github.com/grosucon/mactuck.git
cd mactuck
./scripts/make-cert.sh
./scripts/install.sh
```

What the two scripts do:

1. `make-cert.sh` runs once. It creates a self-signed code-signing certificate
   named `MacTuck Dev` in your login keychain and marks it trusted for code
   signing, which is why macOS asks for your login password. A stable signing
   identity is what lets the Accessibility grant survive rebuilds; with ad-hoc
   signing every rebuild would ask for the permission again.
2. `install.sh` builds a release binary, wraps it in `MacTuck.app`, signs it,
   installs it to `~/Applications`, registers it with Launch Services and
   launches it. Run it again after any change to the source.

On first launch MacTuck opens a small window asking for Accessibility. Open
System Settings › Privacy & Security › Accessibility, switch on MacTuck, and
the window closes by itself. The strip appears over the current app's menu
titles within a second.

## Use

- **Click the pill** to open the dropdown. The app's own menus come first, each
  as a submenu. After a separator: `Exclude <app>`, `MacTuck Settings…`,
  `Quit MacTuck`.
- **Exclude an app** from the dropdown when you want its normal menu bar. To
  bring it back, open Settings from any other app's dropdown and remove it.
- **Settings** has three things: the strip material (the blur behind the
  pill), the excluded apps, and launch at login.

There is deliberately no status item. The dropdown is the whole interface.

## Limits

- macOS 26 draws the menu bar transparent, so the blurred strip is faintly
  visible as a lighter band over the wallpaper.
- Some apps only refresh menu item state when their real menu opens, so an
  item such as `Undo Typing` may show a stale title or enabled state.
- A full-screen app shows no strip on that display; strips on other displays stay.
- Apps that expose no menu bar through Accessibility, mostly Java and X11
  apps, get no strip.

## Uninstall

```sh
pkill -x MacTuck
rm -rf ~/Applications/MacTuck.app
defaults delete com.grosucon.mactuck
```

Then remove MacTuck from System Settings › Privacy & Security › Accessibility,
and, if you want the signing certificate gone too, delete `MacTuck Dev` in
Keychain Access.

## Develop

```sh
swift test                                   # unit tests for the pure core
swift build -c release --product MacTuck     # release build, no bundle
./scripts/install.sh                         # build, sign, install, relaunch
log stream --predicate 'subsystem == "com.grosucon.mactuck"' --level debug --style compact
```

The package has two targets. `MacTuckCore` is pure Swift with no AppKit: the
menu item mapping from Accessibility attributes, the cover geometry, and the
settings stores, all unit tested. `MacTuck` is the AppKit app: Accessibility
reads, the non-activating cover panel, the lazily built `NSMenu`, and the
SwiftUI settings window. A "lift" mode was built, verified and then removed as
more complicated than it was worth.
