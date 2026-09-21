# Build Instructions (Flutter) — منصة المتحكمات

## Prerequisites

- [Flutter SDK 3.35+](https://docs.flutter.dev/get-started/install/linux)
  (stable channel; desktop support enabled)
- CMake, Ninja, Clang/GTK dev files for Linux desktop builds:

  ```bash
  sudo apt-get install -y cmake ninja-build libgtk-3-dev
  ```

- Runtime input injection needs `libevdev` and `/dev/uinput` access:

  ```bash
  sudo apt-get install -y libevdev2
  ```

  Without uinput access the server still runs, but phones are listed as
  "Limited" and no virtual devices are created.

## uinput permissions (one-time setup)

```bash
# Add user to the input groups
sudo groupadd -f uinput
sudo usermod -a -G input,uinput $USER

# Persistent udev rule
sudo sh -c 'echo KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput" > /etc/udev/rules.d/99-uinput.rules'

sudo udevadm control --reload-rules
sudo udevadm trigger /dev/uinput

# Log out and back in for the group changes to take effect
```

## Run / build

```bash
# Fetch dependencies
flutter pub get

# Static analysis + tests (includes real uinput device tests)
flutter analyze
flutter test

# Run the app (single window manages every connected phone)
flutter run -d linux

# Release bundle for distribution
flutter build linux
# -> build/linux/x64/release/bundle/minassat-al-mutahakkamat
```

## Optional: launcher entry

```bash
mkdir -p ~/.local/share/applications ~/.local/share/icons
cp packaging/minassat-al-mutahakkamat.desktop ~/.local/share/applications/
cp assets/logo.png ~/.local/share/icons/minassat-al-mutahakkamat.png
# Edit Exec= to the absolute bundle path first
```

## Settings

Stored as JSON at `~/.config/minassat-al-mutahakkamat/settings.json`
(`port`, `executor`, `mouseSensitivity`). A changed port restarts the
server automatically; a changed executor applies to newly connected phones.
