# Linux Mint Cinnamon CJK / Hangul Input Fix (Fcitx 5 Migration)

An automated tool to resolve Korean (Hangul), Japanese (Mozc), and CJK input method failures inside the **Linux Mint Cinnamon Application Menu search bar**.

---

## ⚡ Quick Install (One-Liner)

Open a terminal (**Ctrl + Alt + T**) and run:

```bash
curl -sL https://raw.githubusercontent.com/kylechoidev/linuxmint-fcitx5-cjk-fix/main/install.sh | sudo bash
```

Once the script finishes, **log out and log back in** (or reboot). 

Korean text composition will now assemble properly in real time directly inside the Cinnamon Application Menu search field.

---

## 🔍 The Problem

On Linux Mint Cinnamon, East Asian input methods (especially Korean Hangul) often work normally inside desktop applications (web browsers, LibreOffice, text editors), but **fail completely inside the Cinnamon Application Menu search bar** (only raw English Latin letters are typed).

### Why Does This Happen?

1. **In-Process Shell Actor vs. GTK Windows**:
   The Cinnamon application menu search field is an internal Clutter/St actor (`StEntry`) running directly within the compositor's main process, rather than a standalone top-level GTK client window.
2. **Linux Mint Default GUI Installs Obsolete Fcitx 4**:
   Linux Mint's default "Input Method" tool (`mintlocale`) has hardcoded package manifests originating from 2018 (`/usr/share/linuxmint/mintlocale/iminfo/fcitx.info`). Selecting Fcitx installs legacy **Fcitx 4**.
3. **Missing D-Bus Input Context Bridge**:
   Upstream Cinnamon fixed desktop shell CJK input via patch `b2c9a19` (*"Fix input method support for CJK languages in menu search and run dialog"*), utilizing **D-Bus-driven text-input context forwarding**. 
   * **Fcitx 5** supports this modern D-Bus interface.
   * **Legacy Fcitx 4** does not, leaving the Cinnamon menu completely unable to bind an active input context.

---

## 🛠️ What This Script Does

1. **Purges Legacy Fcitx 4**: Removes obsolete Fcitx 4 packages without disturbing other desktop dependencies.
2. **Installs the Fcitx 5 Suite**: Installs `fcitx5`, `fcitx5-hangul`, `fcitx5-mozc`, `fcitx5-unikey`, and the Qt configuration utility (`fcitx5-config-qt`).
3. **Installs Required Toolkits**: Installs `fcitx5-frontend-gtk3` (mandatory for Cinnamon's shell), `fcitx5-frontend-gtk4`, `fcitx5-frontend-qt5`, and `fcitx5-frontend-qt6`.
4. **Configures Session via `im-config`**: Sets `run_im fcitx5` in `~/.xinputrc` with appropriate environment parameters (`GTK_IM_MODULE=fcitx`, `QT_IM_MODULE=fcitx`, `XMODIFIERS=@im=fcitx`, `CLUTTER_IM_MODULE=xim`).
5. **Configures Default Input Profile**:
   * Primary: **Keyboard - English (US)**
   * Secondary: **Hangul** (2-Set Dubeolsik)
   * Toggle Hotkeys: Hardware `Hangul` key, `Ctrl + Space`, and `Shift + Space`.
6. **Clears Shortcut Conflicts**: Clears Cinnamon and GNOME's `switch-input-source` `<Super>space` shortcuts that intercept key events before they reach Fcitx.

---

## ⌨️ Hotkeys & Configuration

After logging back in, you can toggle between English and Hangul using:
* Dedicated **Hangul** hardware key (on Korean keyboards)
* **Ctrl + Space**
* **Shift + Space**

To customize your input methods or add other languages (such as Japanese Mozc or Vietnamese Unikey), launch **Fcitx 5 Configuration** from the application menu or run:
```bash
fcitx5-configtool
```

---

## 🧪 Verification

You can verify your Fcitx 5 installation at any time by running:
```bash
fcitx5-diagnose
```

Check that:
* `fcitx5-frontend-gtk3` is listed under Frontends.
* `org.fcitx.Fcitx5` D-Bus service is running.

---

## 🔗 Related Upstream Issues

* [linuxmint/cinnamon#11610](https://github.com/linuxmint/cinnamon/issues/11610) — *Language does not change in cinnamon*
* [linuxmint/mintlocale#85](https://github.com/linuxmint/mintlocale/issues/85) — *Add Fcitx5 support*
* [linuxmint/mintlocale#93](https://github.com/linuxmint/mintlocale/issues/93) — *The input method framework for simplified Chinese should be Fcitx5*

---

## 📄 License

MIT License. Free to use, modify, and distribute.
