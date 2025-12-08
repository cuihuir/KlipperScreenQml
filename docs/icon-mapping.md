# Icon Mapping Documentation
# 图标映射文档

**Purpose**: Map KlipperScreen icon names to QtKs usage locations
**Created**: 2025-12-07

## Core Navigation Icons

| Icon Name | KlipperScreen Usage | QtKs Usage | File Location |
|-----------|---------------------|------------|---------------|
| `home` | Home button | HomePage, GlobalNavButtons | qml/pages/HomePage.qml |
| `back` | Return/Back button | GlobalNavButtons, navigation | qml/components/GlobalNavButtons.qml |
| `settings` | Settings panel | Settings page | qml/pages/SettingsPage.qml |
| `files` | Files panel | Files page | qml/pages/FilesPage.qml |
| `control` | Control panel | Control page | qml/pages/ControlPage.qml |
| `dashboard` | Dashboard | Dashboard page | qml/pages/DashboardPage.qml |

## Printer Control Icons

| Icon Name | Description | Usage |
|-----------|-------------|-------|
| `printer` | 3D printer icon | Main printer status display |
| `extruder` | Extruder/Hotend | Temperature control, extrusion |
| `extruder-0` to `extruder-9` | Numbered extruders | Multi-extruder setups |
| `bed` | Print bed | Bed temperature control |
| `bed-level` | Bed leveling | Bed leveling controls |
| `bed-level-t-l` | Top-left position | Bed leveling grid |
| `bed-level-t-r` | Top-right position | Bed leveling grid |
| `bed-level-center` | Center position | Bed leveling grid |
| `bed-level-b-l` | Bottom-left position | Bed leveling grid |
| `bed-level-b-r` | Bottom-right position | Bed leveling grid |

## Print Control Icons

| Icon Name | Description | Usage |
|-----------|-------------|-------|
| `pause` | Pause print | Print control widget |
| `resume` | Resume print | Print control widget |
| `cancel` | Cancel print | Print control widget |
| `complete` | Print complete | Status display |

## Status Icons

| Icon Name | Description | Usage |
|-----------|-------------|-------|
| `battery-0` | Empty battery | Power status (0%) |
| `battery-25` | Low battery | Power status (25%) |
| `battery-50` | Medium battery | Power status (50%) |
| `battery-75` | Good battery | Power status (75%) |
| `battery-100` | Full battery | Power status (100%) |
| `battery-charging` | Charging | Power status (charging) |
| `battery-unknown` | Unknown state | Power status (unknown) |

## Network Icons

| Icon Name | Description | Usage |
|-----------|-------------|-------|
| `wifi_excellent` | Excellent signal | Network status (>75%) |
| `wifi_good` | Good signal | Network status (50-75%) |
| `wifi_fair` | Fair signal | Network status (25-50%) |
| `wifi_weak` | Weak signal | Network status (<25%) |

## Special Icons

| Icon Name | Description | Notes |
|-----------|-------------|-------|
| `spool` | Filament spool | Uses CSS variables - preprocessed |
| `spoolman` | Spoolman integration | Uses clipPath - handled by Qt |

## Custom Icons Guide

To override any icon:

1. Create your icon file with the same name (e.g., `home.svg`)
2. Place in `assets/custom_icons/` directory
3. Enable in config.json:
   ```json
   {
     "theme": {
       "custom_icons_enabled": true,
       "custom_icons_dir": "assets/custom_icons"
     }
   }
   ```

**Priority Order**: Custom → Theme → Base → Placeholder

## Icon Format Requirements

- **Recommended**: SVG (scalable, theme-aware)
- **Supported**: PNG (fixed size, not recommended for DPI scaling)
- **Size**: 24x24px nominal (will scale based on DPI)
- **Colors**: Use `currentColor` or theme colors for consistency

## Usage in QML

```qml
import "components"

// Basic usage
ThemedIcon {
    iconName: "home"
    iconSize: 48
}

// With DPI scaling
ThemedIcon {
    iconName: "extruder"
    iconSize: 64
    dpiScale: Style.pixelDensity
}

// Dynamic icon
ThemedIcon {
    iconName: printerState === "printing" ? "pause" : "print"
    iconSize: Style.iconSize
}
```
