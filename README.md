# macOS Frosted Carousel Switcher for KDE Plasma (Linux)

> **A high-fidelity, fullscreen 3D carousel application switcher for KDE Plasma with pure monochromatic frosted glass and buttery smooth physics.**

Designed as a premium alternative to standard desktop task switchers, this plugin brings macOS-style Cover Flow / 3D carousel slides to KDE Plasma with live window thumbnails, fullscreen frosted glass backdrop, and responsive keyboard & mouse navigation.

---

## ✨ Features

- **Fullscreen Frosted Glassmorphism**: Complete display overlay with a dark obsidian frosted glass surface (94% opacity) and subtle overhead specular sheen. Completely blocks underlying windows and text from bleeding through.
- **3D Carousel / Cover Flow Slides**: Fluid horizontal layout where windows glide across the screen with damped cubic inertia. Flanking windows tilt with a 24° 3D Y-axis rotation and depth-based scale and opacity falloff.
- **Pure Monochromatic Aesthetics**: No distracting neon or saturated colors. Clean titanium white typography, polished 1px glass refraction rims, and subtle ambient drop glows.
- **Live Running Window Thumbnails**: High-resolution live previews powered by KWin's compositor (`KWin.WindowThumbnail`).
- **Clean Application Info**: Prominent application title and native icon displayed both on the active card and in a floating bottom frosted pill badge. Zero placeholder clutter.
- **Full Navigation Control**:
  - <kbd>Alt</kbd> + <kbd>Tab</kbd> / <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd>
  - Arrow Keys (<kbd>←</kbd> / <kbd>→</kbd> / <kbd>↑</kbd> / <kbd>↓</kbd>)
  - Mouse scroll wheel to glide through open apps
  - Direct mouse click on any card to switch immediately
  - Direct <kbd>✕</kbd> close button on cards to dismiss applications from the switcher
  - <kbd>Esc</kbd> to cancel

---

## 🖥️ Compatibility & System Requirements

This switcher works on **ANY Linux distribution** running the **KDE Plasma** desktop environment:

| Requirement | Details |
|---|---|
| **Supported OS** | Any Linux Distribution (Arch, Fedora, Ubuntu / Kubuntu, Debian, openSUSE, Manjaro, KDE Neon, Kali Linux, EndeavourOS, etc.) |
| **Desktop Environment** | KDE Plasma 6 or KDE Plasma 5 |
| **Compositor / Display Server** | KWin on **Wayland** or **X11** |
| **Dependencies** | Standard KDE Plasma packages (`kirigami`, `plasma-workspace`, `kwin`) |

> **Note on Windows / macOS**: KWin plugins are designed specifically for Linux distributions running the KDE Plasma desktop environment.

---

## 🚀 Easy 1-Click Installation (Recommended)

1. Extract the downloaded package:
   ```bash
   unzip macos-frosted-carousel-switcher-v2.1.0.zip
   cd macos-frosted-carousel-switcher-v2.1.0
   ```

2. Run the automated installer:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. Press <kbd>Alt</kbd> + <kbd>Tab</kbd> immediately! No reboot or logout required.

---

## 🛠️ Manual Installation (Any Linux Distro)

If you prefer installing manually without running the script:

### Step 1: Copy to your local KWin TabBox directory
```bash
mkdir -p ~/.local/share/kwin/tabbox/macos_carousel_switcher/contents/ui
cp metadata.json ~/.local/share/kwin/tabbox/macos_carousel_switcher/
cp contents/ui/* ~/.local/share/kwin/tabbox/macos_carousel_switcher/contents/ui/
```

### Step 2: Register with KPackage
- **KDE Plasma 6**:
  ```bash
  kpackagetool6 --type KWin/WindowSwitcher --install ~/.local/share/kwin/tabbox/macos_carousel_switcher/
  ```
- **KDE Plasma 5**:
  ```bash
  kpackagetool5 --type KWin/WindowSwitcher --install ~/.local/share/kwin/tabbox/macos_carousel_switcher/
  ```

### Step 3: Activate in KWin Configuration
- **KDE Plasma 6**:
  ```bash
  kwriteconfig6 --file kwinrc --group TabBox --key LayoutName "macos_carousel_switcher"
  qdbus6 org.kde.KWin /KWin reconfigure
  ```
- **KDE Plasma 5**:
  ```bash
  kwriteconfig5 --file kwinrc --group TabBox --key LayoutName "macos_carousel_switcher"
  qdbus org.kde.KWin /KWin reconfigure
  ```

---

## ⚙️ GUI Configuration (System Settings)

You can preview and configure the switcher at any time through KDE's native graphical interface:

1. Open **System Settings** (`kcmshell6 kcm_kwintabbox` or search "Task Switcher").
2. Navigate to: **Window Management** ➔ **Task Switcher**.
3. Under **Visualization**, select **macOS Frosted Carousel Switcher**.
4. Click **Apply**.

---

## 🗑️ Uninstallation

To revert to the standard default KDE task switcher:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Or manually:
```bash
kwriteconfig6 --file kwinrc --group TabBox --key LayoutName "thumbnail_grid"
qdbus6 org.kde.KWin /KWin reconfigure
rm -rf ~/.local/share/kwin/tabbox/macos_carousel_switcher
```

---

## ❓ FAQ & Troubleshooting

### Q: Why didn't the switcher change when I pressed Alt+Tab?
KWin Wayland caches loaded switchers in memory. If your desktop session was already running, simply reload KWin configuration with:
```bash
qdbus6 org.kde.KWin /KWin reconfigure
```
Or toggle the switcher selection in **System Settings ➔ Window Management ➔ Task Switcher** and click **Apply**.

### Q: Does it require root or `sudo`?
No. The default installer installs to `~/.local/share/kwin/tabbox/` inside your user directory without needing root permissions.

---

## 📄 License & Distribution
© KDE Studio. Commercial license. You may use this product on all your personal machines. Resale, redistribution, or public rehosting of the source files without authorization is prohibited.
