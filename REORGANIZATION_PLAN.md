# 📁 RENCANA PERAPIAN STRUKTUR FOLDER

## 🎯 PRINSIP PERAPIAN

1. **Setiap file ada di tempat yang semestinya** berdasarkan fungsi
2. **Tidak merusak functionality** - hanya perpindahan + update imports
3. **Konsisten** - pola folder yang sama untuk semua widget
4. **Modular** - separation of concerns yang jelas
5. **Backward compatible** - git commit sebelum perubahan

---

## 📊 STRUKTUR BARU YANG DIUSULKAN

```
quickshell/
├── shell.qml                          # Entry point (TETAP)
├── AGENTS.md, README.md, .gitignore   # Docs (TETAP)
├── matugen.toml                        # Theme config (TETAP)
├── .qmlls.ini                         # QML LSP config (TETAP)
│
├── config/                            # Konfigurasi global (TETAP)
│   ├── Theme.qml
│   ├── Dimens.qml
│   ├── Scales.qml
│   └── Typography.qml
│
├── core/                              # BARU - Core services & state management
│   ├── services/                      # PINDAH dari services/
│   │   ├── AppLauncherService.qml
│   │   ├── CalcService.qml
│   │   ├── CavaService.qml
│   │   ├── ClipboardService.qml
│   │   ├── ColorService.qml
│   │   ├── CurrencyService.qml
│   │   ├── HyprlandDecoration.qml
│   │   ├── MaterialThemeLoader.qml
│   │   ├── NowPlayingService.qml
│   │   ├── PowerService.qml
│   │   ├── RecordService.qml
│   │   ├── ScreenshotService.qml
│   │   ├── SystemInfoService.qml
│   │   ├── WallpaperService.qml
│   │   └── WeatherService.qml
│   │
│   ├── state/                         # BARU - State management
│   │   ├── BarState.qml               # PINDAH dari services/
│   │   ├── BarLayoutState.qml         # PINDAH dari services/
│   │   ├── GlobalState.qml            # PINDAH dari services/
│   │   ├── SysTrayState.qml           # PINDAH dari services/
│   │   └── SysTrayFocusHandler.qml    # PINDAH dari services/
│   │
│   ├── time/                          # BARU - Time utilities
│   │   ├── Time.qml                   # PINDAH dari services/
│   │   └── TimeFloating.qml           # PINDAH dari services/
│   │
│   └── settings/                      # BARU - Settings & data
│       ├── SettingsData.qml           # PINDAH dari services/
│       └── BarPopupState.qml          # PINDAH dari components/widgets/barpopup/
│
├── components/                        # UI Components (TETAP, reorganize internal)
│   ├── elements/                      # Basic elements/icons (TETAP)
│   │   └── [semua Icon*.qml, Shape*.qml, dll]
│   │
│   ├── utils/                         # BARU - Utility components
│   │   ├── Draggable.qml              # PINDAH dari services/
│   │   ├── MarqueeText.qml            # PINDAH dari components/elements/
│   │   ├── HoldButton.qml             # PINDAH dari components/elements/
│   │   └── WaveVisualizer.qml         # PINDAH dari components/elements/
│   │
│   └── widgets/                       # Widget components (TETAP)
│       ├── bar/                       # TETAP
│       │   ├── Bar.qml                # PINDAH dari modules/bar/
│       │   ├── sections/
│       │   └── items/
│       │
│       ├── barpopup/                  # REORGANIZE
│       │   ├── BarPopup.qml           # BARU - consolidated
│       │   ├── BatteryBarPopup.qml
│       │   ├── CalendarCard.qml
│       │   ├── CalendarGlobalOverlay.qml
│       │   ├── PinIndicator.qml
│       │   ├── QuickToggles.qml
│       │   ├── VolumeBrightnessIndicator.qml
│       │   ├── WeatherGlobalOverlay.qml
│       │   ├── sections/
│       │   │   ├── BatteryCard.qml
│       │   │   ├── BrightnessSlider.qml
│       │   │   ├── MediaCard.qml
│       │   │   └── VolumeSection.qml
│       │   └── popups/
│       │       ├── BluetoothPopup.qml
│       │       ├── NotificationPopup.qml
│       │       ├── PowerButton.qml
│       │       ├── PowerPopup.qml
│       │       └── WifiPopup.qml
│       │       # NOTE: services/ dihapus, pindah ke core/services/
│       │
│       ├── applauncher/               # TETAP
│       │   ├── AppLauncher.qml
│       │   ├── CalcPopup.qml
│       │   ├── ClipboardPopup.qml
│       │   ├── ColorPopup.qml
│       │   ├── CurrencyPopup.qml
│       │   ├── GuidePopup.qml
│       │   ├── PowerPopup.qml         # NOTE: cek duplikasi dengan barpopup
│       │   ├── ScreenshotPopup.qml
│       │   ├── SettingsPopup.qml
│       │   ├── SettingsWindow.qml
│       │   ├── WallpaperSwitcher.qml
│       │   └── settings/
│       │       ├── SettingsContent.qml
│       │       ├── components/
│       │       └── pages/
│       │
│       ├── system/                    # TETAP
│       │   ├── ClockWidget.qml
│       │   ├── EqualizerWidget.qml
│       │   ├── QuickActionsWidget.qml
│       │   ├── SystemStatsWidget.qml
│       │   ├── WeatherWidget.qml
│       │   └── metrics/
│       │
│       ├── systemtray/                # TETAP
│       │   ├── MenuItem.qml
│       │   ├── MenuView.qml
│       │   ├── SysTray.qml
│       │   └── SysTrayGlobalOverlay.qml
│       │
│       ├── workspaceswitcher/         # TETAP
│       │   ├── WorkspaceSwitcher.qml
│       │   ├── components/
│       │   └── WorkspaceSwitcherService.qml  # NOTE: pertimbangkan pindah ke core/services/
│       │
│       ├── media/                     # TETAP
│       │   └── nowplaying/
│       │
│       └── misc/                      # TETAP (untuk widget miscellaneous)
│
├── data/                              # Data models (TETAP)
│   └── SearchModel.qml
│
├── screens/                           # Screen layouts (TETAP)
│   ├── Screen.qml
│   └── WelcomeScreen.qml
│
├── scripts/                           # Shell scripts (TETAP)
│   ├── cava_daemon.sh
│   └── vb-control.sh
│
├── savedata/                          # Persistent data (TETAP)
│   └── [semua JSON files]
│
└── icons/                             # Static icons (TETAP)
    └── music-note.svg
```

---

## 🔄 MAPPING PERPINDAHAN FILE

### **1. services/ → core/services/**
```
services/AppLauncherService.qml     → core/services/AppLauncherService.qml
services/CalcService.qml            → core/services/CalcService.qml
services/CavaService.qml            → core/services/CavaService.qml
services/ClipboardService.qml       → core/services/ClipboardService.qml
services/ColorService.qml           → core/services/ColorService.qml
services/CurrencyService.qml        → core/services/CurrencyService.qml
services/HyprlandDecoration.qml     → core/services/HyprlandDecoration.qml
services/MaterialThemeLoader.qml    → core/services/MaterialThemeLoader.qml
services/NowPlayingService.qml      → core/services/NowPlayingService.qml
services/PowerService.qml           → core/services/PowerService.qml
services/RecordService.qml          → core/services/RecordService.qml
services/ScreenshotService.qml      → core/services/ScreenshotService.qml
services/SystemInfoService.qml      → core/services/SystemInfoService.qml
services/WallpaperService.qml       → core/services/WallpaperService.qml
services/WeatherService.qml         → core/services/WeatherService.qml
```

### **2. services/ → core/state/**
```
services/BarState.qml               → core/state/BarState.qml
services/BarLayoutState.qml         → core/state/BarLayoutState.qml
services/GlobalState.qml            → core/state/GlobalState.qml
services/SysTrayState.qml           → core/state/SysTrayState.qml
services/SysTrayFocusHandler.qml    → core/state/SysTrayFocusHandler.qml
```

### **3. services/ → core/time/**
```
services/Time.qml                   → core/time/Time.qml
services/TimeFloating.qml           → core/time/TimeFloating.qml
```

### **4. services/ → core/settings/**
```
services/SettingsData.qml           → core/settings/SettingsData.qml
```

### **5. components/widgets/barpopup/ → core/settings/**
```
components/widgets/barpopup/BarPopupState.qml → core/settings/BarPopupState.qml
```

### **6. services/ → components/utils/**
```
services/Draggable.qml              → components/utils/Draggable.qml
```

### **7. components/elements/ → components/utils/**
```
components/elements/MarqueeText.qml      → components/utils/MarqueeText.qml
components/elements/HoldButton.qml       → components/utils/HoldButton.qml
components/elements/WaveVisualizer.qml   → components/utils/WaveVisualizer.qml
```

### **8. modules/bar/ → components/widgets/bar/**
```
modules/bar/Bar.qml                 → components/widgets/bar/Bar.qml
modules/ folder dihapus
```

### **9. components/widgets/barpopup/services/ → core/services/**
```
components/widgets/barpopup/services/BrightnessService.qml → core/services/BrightnessService.qml
components/widgets/barpopup/services/MprisService.qml      → core/services/MprisService.qml
components/widgets/barpopup/services/NotificationService.qml → core/services/NotificationService.qml
components/widgets/barpopup/services/PipewireService.qml   → core/services/PipewireService.qml
```

### **10. components/widgets/workspaceswitcher/ → core/services/**
```
components/widgets/workspaceswitcher/WorkspaceSwitcherService.qml → core/services/WorkspaceSwitcherService.qml
```

---

## 📝 UPDATE IMPORTS YANG DIPERLUKAN

### **shell.qml**
```qml
// SEBELUM:
import qs.services
import qs.components.widgets.barpopup
import qs.components.widgets.barpopup.services
import qs.components.widgets.workspaceswitcher
import qs.components.widgets.applauncher
import qs.modules.bar

// SESUDAH:
import qs.core.services
import qs.core.state
import qs.core.time
import qs.core.settings
import qs.components.widgets.bar
import qs.components.widgets.barpopup
import qs.components.widgets.workspaceswitcher
import qs.components.widgets.applauncher
```

### **File-file yang import dari qs.services**
Semua file yang punya `import qs.services` perlu diupdate sesuai lokasi baru:
- Jika pakai BarState, BarLayoutState → `import qs.core.state`
- Jika pakai Time → `import qs.core.time`
- Jika pakai SettingsData → `import qs.core.settings`
- Jika pakai services → `import qs.core.services`

### **File-file yang import dari qs.components.widgets.barpopup.services**
```qml
// SEBELUM:
import qs.components.widgets.barpopup.services

// SESUDAH:
import qs.core.services
```

### **BarPopupState.qml** (dipindah ke core/settings/)
```qml
// SEBELUM:
import qs.services

// SESUDAH:
import qs.core.state      # untuk SysTrayState
```

---

## ⚠️ YANG TIDAK DIUBAH

1. **`components/elements/`** - Icon dan shape files tetap di sana (kecuali utility components)
2. **`components/widgets/*/`** - Struktur widget tetap, hanya services yang dipisah
3. **`config/`** - Tetap di tempat
4. **`data/`** - Tetap di tempat
5. **`screens/`** - Tetap di tempat
6. **`scripts/`** - Tetap di tempat
7. **`savedata/`** - Tetap di tempat
8. **`icons/`** - Tetap di tempat
9. **Semua logic/code di dalam file** - TIDAK DIUBAH, hanya import paths

---

## 🎯 KEUNTUNGAN STRUKTUR BARU

1. ✅ **Separation of Concerns** - Services, state, utils terpisah jelas
2. ✅ **Konsisten** - semua services di `core/services/`, state di `core/state/`
3. ✅ **Mudah dicari** - nama folder sesuai fungsi
4. ✅ **Scalable** - gampang nambah services/widgets baru
5. ✅ **Tidak breaking** - hanya update import paths, logic tetap
6. ✅ **Clean modules/** - `modules/` dihapus, Bar pindah ke components

---

## 🔍 FILE YANG PERLU CEK DUPLIKASI

1. **PowerPopup.qml** - Ada di:
   - `components/widgets/applauncher/PowerPopup.qml`
   - `components/widgets/barpopup/popups/PowerPopup.qml`
   → Perlu dicek apakah sama atau beda fungsi

2. **MenuItem.qml** - Ada di:
   - `components/widgets/bar/items/MenuItem.qml`
   - `components/widgets/systemtray/MenuItem.qml`
   → Perlu dicek apakah bisa direuse

---

## 📋 CHECKLIST SEBELUM EKSEKUSI

- [ ] Backup dengan git commit
- [ ] Cek semua file yang akan dipindah
- [ ] Scan semua import di seluruh project
- [ ] Buat mapping import yang perlu diupdate
- [ ] Test quickshell setelah perubahan
- [ ] Report error jika ada

---

## 🚀 EKSEKUSI PLAN

1. **Commit current state**
2. **Buat folder baru**: `core/services/`, `core/state/`, `core/time/`, `core/settings/`, `components/utils/`
3. **Pindahkan files** sesuai mapping
4. **Update semua imports** di file-file yang affected
5. **Update shell.qml** imports
6. **Hapus folder kosong**: `services/`, `modules/`, `components/widgets/barpopup/services/`
7. **Test** quickshell reload
8. **Report** hasil

---

**APAKAH ANDA SETUJU DENGAN RENCANA INI?**
Atau ada yang ingin diubah/ditambahkan?
