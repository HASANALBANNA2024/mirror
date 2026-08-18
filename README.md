# 🪞 Smart Mirror App (Reflect Your Style)

A premium, fast, and feature-rich real-time smart mirror application built with Flutter. It utilizes hardware-accelerated HD camera rendering, intelligent gestures, built-in system states caching, and custom photo studio filters to deliver an elegant native iOS/OnePlus-like camera experience.

---

## ✨ Features Breakdown

### 📹 Pro Camera Engine & Live Feed
* **HD View Native Rendering:** Uses Flutter's CameraPreview combined with FittedBox and OverflowBox to maximize original camera sensor quality without skewing aspect ratios.
* **Freeze Frame (Pause/Resume):** Toggle live preview freezing seamlessly using hardware preview management (resumePreview/pausePreview).
* **Interactive Smart Zoom:** Supports unified linear slider adjustments and professional 2-finger multi-touch gestures using custom TransformationController scaled systematically from 1.0x to 5.0x.

### 🎛️ Studio Exposure & Lighting Ecosystem
* **Ambient Lighting Aura Borders:** Custom custom-clipped active lighting framework (AuraMirrorBorder) that modifies physical UI brightness levels mimicking hardware studio ring-lights.
* **Dynamic Exposure Tone Mapping:** Instantly alters active camera matrix hardware exposure offsets:
    * **Warm Light:** Yellow-Orange Hue Multipliers (alpha: 0.12) with +0.3 exposure correction.
    * **Cold Light:** Pale Blue Balanced Overlays (alpha: 0.08) with +0.2 exposure correction.
    * **Low Light:** High Exposure Gain compensation scaling up to +1.2.

### 📸 Capture Utilities & Media Management
* **Sequential Hardware Timers:** Built-in asynchronous loop countdown intervals supporting custom 3-second and 5-second automatic snapshot actions.
* **Gal Engine Native Persistence:** Saved imagery is natively committed straight into the host system's hardware image directory instantly using platform channels.
* **State Caching System:** Uses custom SharedPreferences background disk writing layers to recall user media collections dynamically across hot reboots.
* **In-App Media Gallery Hub:** Responsive sliding image preview drawer featuring long-press multi-selection arrays, multi-image unified system native sharing arrays via SharePlus framework, and instant system array purging capabilities.

---

## 📂 Project Architecture & Directory Mapping

The codebase enforces a clean separation of concerns under a scalable domain/feature directory setup:

lib/
├── logics/
│   └── mirror_logic.dart           # Decoupled Core State & Hardware Camera Initializer
├── screens/
│   ├── mirror_screen.dart          # Master Coordinator & Main Workspace Pipeline
│   └── splash_screen.dart          # Native Hydration Layer & Logo Fade Entryway
├── service/
│   └── mirror_gallery_service.dart # File System Persister, In-App Gallery Layout & Action Hooks
├── widgets/
│   ├── mirror_frame_widgets.dart   # Camera Preview Composites & Absolute Position Controls
│   ├── mirror_settings_panel.dart  # Horizontal Filter Selection Bar & Micro-sliders
│   └── mirror_widgets.dart         # Custom Painters, Grids, and Glass Layer Materials
└── main.dart                       # App Native Initialization & Global Entrypoint

---

## 🖼️ Application Screenshots Index

The official design assets and visual components are structuralized in the system root repository directory:

screenshots/
├── native_splash_screen.png        # Core System Bootstrap Hydration Splash Face
├── splash_screen.png               # Interactive UI Logo Animated Inward Entry Screen
├── mirror_off_mode_with settings.png # Default HD View Grid Layout & Workspace Controls
└── mirror_on_settings.png          # Active Exposure Overlay Setup & Filter Selection Deck

---

## 🛠️ Technological Frameworks & Dependencies

This software project runs on the latest stable Flutter ecosystem engineered with the following robust packages:

* **camera:** Low-level camera lens streaming, focus controls, and preview matrix access.
* **share_plus:** Native platform content sheets for external media broadcasting.
* **shared_preferences:** Key-Value offline atomic caching for persistent image indexes.
* **gal:** Fast cross-platform local photo gallery hardware save integration.
* **flutter_native_splash:** Eliminates blank white boots by keeping native splash responsive until UI is fully active.
* **vector_math:** Mathematical matrix transformation tools driving linear zoom vectors.

---

## ⚡ Setup & Local Installation

Follow these easy steps to setup and test the Smart Mirror application locally:

### 1. Requirements Checklist
* Flutter SDK (3.22.0 or higher recommended)
* Android SDK API Level 21+ / iOS 11.0+
* Real hardware device (Front camera access is mandatory)

### 2. Clone and Initialize Project
* Run: flutter pub get (To fetch and configure project dependencies)

### 3. Permissions Setup
Ensure your target host system possesses the required configurations:

* **Android (AndroidManifest.xml):**
    * <uses-permission android:name="android.permission.CAMERA" />
    * <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28"/>

* **iOS (Info.plist):**
    * NSCameraUsageDescription: Smart Mirror needs camera access to display your reflection.
    * NSPhotoLibraryAddUsageDescription: Smart Mirror needs permission to save captured snapshots to your device.

### 4. Build and Run
* Run: flutter analyze (To verify code health and linting rules)
* Run: flutter run --release (To compile and install to your connected smartphone)

---

## 🎨 UI Stylebook Specifications
* **Primary Theme:** Strict ThemeData(brightness: Brightness.dark) contrast structure.
* **Background Spectrum:** Midnight Jet Black (#121212) minimizing screen reflection noise.
* **Aura Glow Output:** Natural Warm Soft White Emulation (#FFF4D2).
* **Interactive Highlights:** High Visibility Cyber Yellow (Colors.yellow) for active adjustments.