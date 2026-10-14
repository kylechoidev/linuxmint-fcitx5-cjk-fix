# Linux Mint Cinnamon CJK Input Fix (Fcitx 5 Migration)
### Full Support for Korean (Hangul), Japanese (Mozc), Chinese (Pinyin / Chewing / Table), and Vietnamese (UniKey)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Linux Mint](https://img.shields.io/badge/Platform-Linux%20Mint%2021%20%7C%2022-brightgreen.svg)](https://linuxmint.com)
[![Desktop: Cinnamon](https://img.shields.io/badge/Desktop-Cinnamon-orange.svg)](https://github.com/linuxmint/cinnamon)

An automated script to resolve **Korean, Japanese, Chinese, and Vietnamese** input method failures inside the **Linux Mint Cinnamon Application Menu search bar**.

---

## ⚡ Quick Install (One-Liner)

Open your terminal (**Ctrl + Alt + T**) and run:

```bash
curl -sL https://raw.githubusercontent.com/kylechoidev/linuxmint-fcitx5-cjk-fix/main/install.sh | sudo bash
```

Once the script finishes, **log out of your Cinnamon session and log back in** (or reboot). 

East Asian text composition will now assemble properly in real time directly inside the Cinnamon Application Menu search field.

---

## 🌐 Multi-Language Support (J, C, K, V)

The migration script pre-installs the complete modern **Fcitx 5 engine suite** for all major East Asian and Southeast Asian writing systems:

| Language | Engine Package | Input Method in Fcitx 5 | Supported Scripts / Features |
|:---|:---|:---|:---|
| **Japanese (日本語)** | `fcitx5-mozc` | **Mozc** | Hiragana, Katakana, Kanji, Google Mozc dictionary |
| **Chinese (Simplified)** | `fcitx5-chinese-addons` | **Pinyin** (拼音) / **Table** | Full Pinyin, Shuangpin, Wubi, Stroke |
| **Chinese (Traditional)** | `fcitx5-chewing` | **Chewing** (酷音) | Zhuyin / Bopomofo (注音符號) |
| **Korean (한국어)** | `fcitx5-hangul` | **Hangul** (한글) | 2-Set Dubeolsik, 3-Set Sebeolsik, Hanja |
| **Vietnamese (Tiếng Việt)** | `fcitx5-unikey` | **UniKey** | Telex, VNI, VIQR, Simple Telex |

> **Automatic Locale Detection**:
> If your system language (`$LANG`) is set to Japanese, Chinese, Korean, or Vietnamese, the script **automatically selects your native language as the default secondary input method**.
> If your system is set to English or another language, you can enable any language in seconds using the GUI.

---

## ⚙️ How to Add, Switch, or Customize Your Languages

You can easily add, remove, or reorder your input methods using the native graphical configuration tool:

1. Open the application menu and search for **Fcitx 5 Configuration** (or press `Alt + F2` and run `fcitx5-configtool`).
2. Under the **Input Method** tab:
   * **Left Panel ("Current Input Method")**: Lists your active input methods. The top entry is your default alphanumeric layout (e.g., `Keyboard - English (US)`).
   * **Right Panel ("Available Input Method")**: Shows engines available to add.
3. **To add a language**:
   * Click the **`+` (Add)** button.
   * **Important**: Uncheck the box **"Only Show Current Language"** to view all installed engines.
   * Search for your language:
     * Type `Mozc` for Japanese.
     * Type `Pinyin` or `Chewing` for Chinese.
     * Type `Hangul` for Korean.
     * Type `UniKey` for Vietnamese.
   * Select it and click **OK**.
4. Use the **Up/Down arrows** to arrange your switching order, then click **Apply**.

---

## ⌨️ Switching Hotkeys

You can toggle between English and your chosen language using:
* **Ctrl + Space** (universal default)
* **Shift + Space**
* Dedicated **Hangul** key (Korean keyboards)
* Dedicated **Zenkaku/Hankaku (全角/半角)** or **Muhenkan/Henkan** keys (Japanese keyboards)

To change hotkeys, navigate to **Global Options** inside `fcitx5-configtool` and click on **Trigger Keys**.

---

## 🔍 Root Cause: Why Does Cinnamon Fail with Default Fcitx?

On Linux Mint Cinnamon, Asian text input typically functions inside standard GUI apps (browsers, text editors), but **fails completely inside the Cinnamon Application Menu search bar** (typing only emits Latin characters).

### The Technical Reason:

1. **In-Process Shell Actor vs. Top-Level GTK Windows**:
   Standard apps run as independent top-level GTK/Qt surfaces that load input method modules directly into the client process. The Cinnamon application menu search field is an internal Clutter/St actor (`StEntry`) executing directly within Cinnamon’s main compositor event loop.
2. **Outdated Linux Mint Manifests**:
   Linux Mint's "Input Method" tool (`mintlocale`) contains hardcoded package lists frozen since **September 2018** (`/usr/share/linuxmint/mintlocale/iminfo/fcitx.info`). Selecting Fcitx installs legacy **Fcitx 4**.
3. **Upstream D-Bus Requirement**:
   Upstream Cinnamon modernized desktop shell CJK input (patch `b2c9a19`), adopting **D-Bus-driven text-input context forwarding**.
   * **Fcitx 5** communicates natively via this D-Bus interface.
   * **Legacy Fcitx 4** relies on older XIM sockets that cannot establish an active input context (`IC`) within the in-process Clutter actor, causing key events to bypass composition and commit directly as raw Latin text.

---

## 🛠️ Complete Overview of Script Actions

1. **Safe Legacy Purge**: Removes legacy Fcitx 4 packages without removing Cinnamon or any desktop dependencies (`autoremove --purge`).
2. **Installs Full Fcitx 5 Stack**: Deploys `fcitx5`, `fcitx5-hangul`, `fcitx5-mozc`, `fcitx5-chinese-addons`, `fcitx5-chewing`, `fcitx5-unikey`, and `fcitx5-config-qt`.
3. **Deploys Mandatory Frontend Toolkits**: Installs `fcitx5-frontend-gtk3` (mandatory for Cinnamon's shell / `StEntry`), `fcitx5-frontend-gtk4`, `fcitx5-frontend-qt5`, and `fcitx5-frontend-qt6`.
4. **Session Integration via `im-config`**: Sets `run_im fcitx5` in `~/.xinputrc`, ensuring `GTK_IM_MODULE=fcitx`, `QT_IM_MODULE=fcitx`, `XMODIFIERS=@im=fcitx`, and `CLUTTER_IM_MODULE=xim` are correctly exported at login.
5. **Generates User Profile**: Configures the initial profile in `~/.config/fcitx5/profile` tailored to the user's detected locale.
6. **Clears Desktop Shortcut Collisions**: Automatically unbinds Cinnamon and GNOME's conflicting `switch-input-source` `<Super>space` keybindings that hijack switching hotkeys.

---

## 🧪 Post-Install Diagnostic

To verify that all modules and D-Bus services are properly loaded:
```bash
fcitx5-diagnose
```

Ensure that:
* `fcitx5-frontend-gtk3` is loaded under **Frontends**.
* `org.fcitx.Fcitx5` owns its D-Bus service endpoint under **User Interface**.

---

## 🔗 Related Upstream Issues

* [linuxmint/cinnamon#11610](https://github.com/linuxmint/cinnamon/issues/11610) — *Language does not change in cinnamon*
* [linuxmint/mintlocale#85](https://github.com/linuxmint/mintlocale/issues/85) — *Add Fcitx5 support*
* [linuxmint/mintlocale#93](https://github.com/linuxmint/mintlocale/issues/93) — *The input method framework for simplified Chinese should be Fcitx5*

---

## 📄 License

MIT License. Free to use, modify, and distribute.
