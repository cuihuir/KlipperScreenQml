# Feature Specification: KlipperScreen UI Assets Integration

**Feature Branch**: `002-ui-assets`
**Created**: 2025-12-07
**Status**: Draft
**Input**: User description: "UI也直接使用KlipperScreen的素材"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Visual Consistency with KlipperScreen (Priority: P1)

Users need the interface to look identical to KlipperScreen, using the same icons, colors, fonts, and visual styling so that the QML version feels like a familiar, native experience rather than a different application.

**Why this priority**: Visual consistency is critical for user acceptance. Users migrating from KlipperScreen GTK to QtKs expect to see the same interface they're familiar with. Different icons or colors would create confusion and resistance to adoption.

**Independent Test**: Can be fully tested by placing screenshots of QtKs and KlipperScreen side-by-side and verifying icons, colors, button styles, and typography match within acceptable tolerance (accounting for GTK vs QML rendering differences).

**Acceptance Scenarios**:

1. **Given** the main menu is displayed, **When** user views panel icons, **Then** all icons (move, temperature, fan, bed, extrude, etc.) are identical to KlipperScreen's SVG icons
2. **Given** any panel is displayed, **When** user observes colors, **Then** background colors, button colors, text colors, and accent colors match KlipperScreen's theme exactly
3. **Given** the temperature graph is visible, **When** user views heater curves, **Then** temperature curve colors (color1-color4) match KlipperScreen's palette
4. **Given** action buttons are displayed, **When** user views emergency stop, shutdown, back, home buttons, **Then** icons and styling match KlipperScreen's action bar buttons
5. **Given** the interface displays text, **When** user reads labels and values, **Then** font family, sizes, and weights match KlipperScreen's typography

---

### User Story 2 - Theme Support (Priority: P1)

Users need access to KlipperScreen's built-in themes (material-dark, material-darker, material-light, colorized, z-bolt) so they can customize their interface appearance to match their preferences and hardware display characteristics.

**Why this priority**: Theme selection is a core customization feature in KlipperScreen. Users have specific preferences based on ambient lighting, personal taste, and display hardware. Without theme support, the interface is less flexible than the original.

**Independent Test**: Can be tested by configuring each available theme in the config file, restarting the application, and verifying the interface matches KlipperScreen's appearance for that theme.

**Acceptance Scenarios**:

1. **Given** material-dark theme is configured, **When** application launches, **Then** interface uses material-dark color scheme and icons matching KlipperScreen's material-dark theme
2. **Given** material-light theme is configured, **When** application launches, **Then** interface uses light backgrounds, dark text, and light-theme icons
3. **Given** user switches themes via configuration, **When** application restarts, **Then** all colors, icons, and styles update to reflect the new theme
4. **Given** a theme is active, **When** user views all panels, **Then** theme consistency is maintained across all screens without color or icon mismatches

---

### User Story 3 - Icon Set Completeness (Priority: P1)

Users need all UI elements to display with proper icons from KlipperScreen's icon library (100+ icons) ensuring no missing or placeholder icons appear in the interface.

**Why this priority**: Missing icons create an incomplete, unprofessional appearance and reduce usability. Every button, status indicator, and panel needs its corresponding icon for proper visual communication.

**Independent Test**: Can be tested by navigating through all panels and features, creating a checklist of all icons used, and verifying each icon loads correctly from KlipperScreen's assets.

**Acceptance Scenarios**:

1. **Given** user navigates to any panel, **When** viewing the interface, **Then** all panel icons display correctly without missing image indicators
2. **Given** printer has multiple extruders, **When** viewing extruder controls, **Then** each extruder shows the correct numbered icon (extruder-0, extruder-1, etc.)
3. **Given** user views status indicators, **When** observing WiFi, battery, heating, printing status, **Then** appropriate icons display for each state
4. **Given** user accesses settings or system panels, **When** viewing menu items, **Then** all menu items display with their corresponding icons

---

### User Story 4 - Asset Loading and Performance (Priority: P1)

Users need UI assets to load quickly without delays or flickering so the interface remains responsive and professional-looking during navigation and screen transitions.

**Why this priority**: Slow asset loading degrades user experience. 3D printing requires quick access to controls for safety and efficiency. Assets must load instantly to maintain responsiveness.

**Independent Test**: Can be tested by navigating rapidly between panels, monitoring asset load times, and verifying no placeholder icons or delayed rendering occurs.

**Acceptance Scenarios**:

1. **Given** user navigates to a new panel, **When** panel loads, **Then** all icons and images appear within 100ms without flickering or placeholders
2. **Given** user switches themes, **When** application restarts, **Then** all theme assets load completely before main menu displays
3. **Given** interface is running for extended periods, **When** user continues using the application, **Then** asset rendering remains smooth without memory leaks or degradation
4. **Given** temperature graph updates, **When** graph redraws, **Then** rendering occurs at 30fps minimum without dropped frames

---

### User Story 5 - Custom Icon Support (Priority: P2)

Users need the ability to add custom icons for custom panels or macros, following KlipperScreen's custom icon conventions, allowing personalization and extension beyond stock icons.

**Why this priority**: Advanced users create custom panels and macros. While not essential for basic operation, custom icon support enables full feature parity with KlipperScreen's extensibility.

**Independent Test**: Can be tested by adding a custom SVG icon to the appropriate directory, configuring a custom panel or macro to use it, and verifying the custom icon displays correctly.

**Acceptance Scenarios**:

1. **Given** user adds a custom SVG icon to the icons directory, **When** panel configuration references the custom icon, **Then** the custom icon displays in the interface
2. **Given** user creates a custom macro with custom icon, **When** viewing the macros panel, **Then** the macro button shows the custom icon
3. **Given** custom icon doesn't exist, **When** interface attempts to load it, **Then** a default fallback icon displays without crashing

---

### User Story 6 - High-DPI and Resolution Scaling (Priority: P2)

Users need icons and assets to scale properly on different display resolutions and DPI settings, maintaining visual quality on both standard 800x480 displays and higher resolution screens.

**Why this priority**: Different printer setups use different display hardware. SVG assets must scale properly to maintain quality across resolutions without pixelation.

**Independent Test**: Can be tested by running the application on different display resolutions (800x480, 1024x600, 1920x1080) and verifying icons remain sharp and properly sized.

**Acceptance Scenarios**:

1. **Given** display resolution is 800x480, **When** viewing the interface, **Then** icons render at appropriate size for touch interaction (minimum 48x48px touch targets)
2. **Given** display resolution is higher than 800x480, **When** viewing icons, **Then** SVG icons scale up without pixelation or quality loss
3. **Given** display has high DPI, **When** rendering the interface, **Then** icons scale appropriately for DPI without appearing too small or too large

---

### Edge Cases

- What happens when a theme directory is missing or corrupted? System should fall back to base.css defaults and log warning without crashing
- How does system handle missing icon files referenced in configuration? System should use a generic fallback icon and log the missing asset
- What happens when SVG files are malformed or invalid? System should display a placeholder icon and continue operation without crashing
- How does system handle theme switching while application is running? System requires restart to apply new theme (matching KlipperScreen behavior)
- What happens when custom icons are provided in unsupported formats (PNG, JPG instead of SVG)? System should support multiple formats with preference for SVG
- How does system handle very large icon files that could impact performance? System should load icons asynchronously and cache them
- What happens when color definitions are missing from theme CSS? System should fall back to base color definitions

## Requirements *(mandatory)*

### Functional Requirements

**Asset Integration**

- **FR-001**: System MUST use KlipperScreen's SVG icon library directly from the KlipperScreen/styles directory structure
- **FR-002**: System MUST load all theme assets (icons, colors, fonts) from KlipperScreen's styles directory
- **FR-003**: System MUST support all KlipperScreen themes: material-dark, material-darker, material-light, colorized, and z-bolt
- **FR-004**: System MUST read and apply theme colors from KlipperScreen's CSS color definitions (@define-color variables)
- **FR-005**: System MUST maintain the same directory structure for assets: styles/[theme-name]/images/ for icons

**Icon Management**

- **FR-006**: System MUST load all 100+ icons from KlipperScreen's icon library including panel icons, status icons, action icons, and device icons
- **FR-007**: System MUST support numbered extruder icons (extruder-0 through extruder-9) for multi-extruder configurations
- **FR-008**: System MUST use appropriate icons for all printer states (idle, printing, paused, error, heating, etc.)
- **FR-009**: System MUST display bed leveling position icons for all grid positions (bed-level-t-l, bed-level-t-r, etc.)
- **FR-010**: System MUST use battery status icons showing charge levels (battery-0, battery-25, battery-50, battery-75, battery-100, battery-charging, battery-unknown)
- **FR-011**: System MUST use WiFi signal strength icons (wifi_excellent, wifi_good, wifi_fair, wifi_poor)
- **FR-012**: System MUST support custom icons placed in the styles/[theme-name]/images/ directory

**Theme Application**

- **FR-013**: System MUST parse KlipperScreen's CSS files to extract color definitions for use in QML styling
- **FR-014**: System MUST apply theme colors to all UI elements including backgrounds, buttons, text, borders, and graphs
- **FR-015**: System MUST use theme-specific icons when available, falling back to base icons when theme doesn't provide custom icons
- **FR-016**: System MUST apply temperature graph colors (color1, color2, color3, color4) from theme definitions
- **FR-017**: System MUST use theme-defined accent colors for active states, warnings, and errors
- **FR-018**: System MUST respect theme font size definitions (KS_FONT_SIZE placeholder) when available

**Color System**

- **FR-019**: System MUST implement all base color definitions: color1 (orange #ED6500), color2 (magenta #B10080), color3 (teal #009384), color4 (lime #A7E100)
- **FR-020**: System MUST implement semantic colors: bg (background), active (active state), echo (confirmation), warning, error
- **FR-021**: System MUST implement text colors: text (primary), text-inv (inverse), lines (borders/separators)
- **FR-022**: System MUST allow themes to override base colors with theme-specific color definitions
- **FR-023**: System MUST apply colors consistently across all UI components (buttons, labels, backgrounds, borders)

**Asset Loading**

- **FR-024**: System MUST load theme configuration at application startup before rendering UI
- **FR-025**: System MUST cache loaded icons in memory to prevent redundant file reads
- **FR-026**: System MUST support lazy loading of icons that aren't immediately visible
- **FR-027**: System MUST load SVG icons as vector graphics to support resolution-independent scaling
- **FR-028**: System MUST fall back to base theme assets when selected theme is unavailable
- **FR-029**: System MUST validate icon files exist before attempting to load them

**Resolution and Scaling**

- **FR-030**: System MUST scale icons proportionally based on display resolution and DPI
- **FR-031**: System MUST maintain minimum touch target sizes (48x48px) regardless of icon scaling
- **FR-032**: System MUST render SVG icons without pixelation at any supported resolution
- **FR-033**: System MUST apply consistent scaling to all icons within a panel
- **FR-034**: System MUST support display resolutions from 800x480 up to 1920x1080

**Custom Assets**

- **FR-035**: System MUST support custom icons in SVG format placed in theme directories
- **FR-036**: System MUST support custom panel icons referenced in configuration files
- **FR-037**: System MUST support custom macro icons specified in macro definitions
- **FR-038**: System MUST validate custom icon files are readable before attempting to load
- **FR-039**: System MUST provide fallback icon when custom icon is missing or invalid

**Error Handling**

- **FR-040**: System MUST display a default placeholder icon when requested icon file is missing
- **FR-041**: System MUST log warnings for missing icons without crashing the application
- **FR-042**: System MUST fall back to base theme when selected theme directory is missing or corrupted
- **FR-043**: System MUST handle malformed SVG files gracefully by using placeholder icon
- **FR-044**: System MUST continue operation when CSS color definitions are missing, using hardcoded defaults

**Typography**

- **FR-045**: System MUST use font family matching KlipperScreen's typography (system default sans-serif)
- **FR-046**: System MUST implement font size scaling based on theme definitions and display resolution
- **FR-047**: System MUST apply consistent font weights matching KlipperScreen's visual hierarchy
- **FR-048**: System MUST ensure text remains legible at all supported resolutions

**Configuration**

- **FR-049**: System MUST read theme selection from configuration file (style setting in KlipperScreen.conf)
- **FR-050**: System MUST support theme switching via configuration file modification and application restart
- **FR-051**: System MUST persist theme selection across application restarts
- **FR-052**: System MUST validate theme names in configuration against available themes

### Key Entities *(include if feature involves data)*

- **Theme**: Represents a visual style including icon set, color palette, and CSS definitions with name, base directory path, and configuration
- **IconAsset**: Individual icon file with file path, SVG data, cache status, and metadata (size, format)
- **ColorPalette**: Set of color definitions including primary colors (color1-4), semantic colors (bg, active, warning, error), and text colors
- **AssetCache**: In-memory cache of loaded icons and theme resources to improve performance
- **ThemeConfiguration**: Parsed theme settings from CSS/conf files including color mappings, font sizes, and icon overrides

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Visual comparison between QtKs and KlipperScreen screenshots shows 98%+ visual similarity in layout, colors, and icons
- **SC-002**: All 100+ KlipperScreen icons load and display correctly without missing or placeholder icons during normal operation
- **SC-003**: Icon loading performance achieves <50ms per icon on first load, <5ms on cached loads
- **SC-004**: Theme switching completes within 3 seconds from application launch to fully rendered main menu
- **SC-005**: Memory usage for cached assets remains under 20MB for complete icon library
- **SC-006**: SVG icons render sharply at all supported resolutions (800x480 to 1920x1080) without pixelation
- **SC-007**: All 5 KlipperScreen themes (material-dark, material-darker, material-light, colorized, z-bolt) are functional and visually accurate
- **SC-008**: Color accuracy matches KlipperScreen's color definitions within 2% RGB tolerance (accounting for QML vs GTK rendering)
- **SC-009**: Users can successfully add and use custom icons for custom panels without requiring code changes
- **SC-010**: Zero crashes or errors occur due to missing, corrupted, or malformed asset files
- **SC-011**: Font rendering matches KlipperScreen's typography with same relative sizes and weights across all screen elements
- **SC-012**: Asset loading has no measurable impact on panel navigation responsiveness (<100ms additional load time per panel)

## Assumptions

- Asset format compatibility: Assuming QML can render SVG files from KlipperScreen without conversion or modification
- CSS parsing: Assuming CSS color definitions can be parsed and converted to QML color format programmatically
- File system access: Assuming read access to KlipperScreen/styles directory and its subdirectories
- Icon naming consistency: Assuming icon file names in KlipperScreen remain stable and consistent
- SVG compatibility: Assuming KlipperScreen's SVG icons use standard SVG 1.1 features supported by Qt's QML SVG renderer
- Color space: Assuming RGB color space is consistent between GTK and QML rendering
- Font availability: Assuming system fonts used by KlipperScreen are available on target systems
- Theme structure: Assuming KlipperScreen's theme directory structure remains stable (styles/theme-name/images/)
- Default theme: Assuming material-dark as default theme when no theme is configured
- Asset licensing: Assuming KlipperScreen's assets can be used in derivative works (both projects are open source)
- Icon sizes: Assuming base icon size of 48x48px for touch targets with scaling for larger displays
- Cache behavior: Assuming in-memory icon caching is acceptable without disk-based cache
- Theme completeness: Assuming all themes provide complete icon sets or properly fall back to base icons

## Dependencies

- KlipperScreen repository: Source of all UI assets (icons, styles, themes)
- KlipperScreen/styles directory: Contains theme directories with icons and CSS files
- Qt SVG module: QML SVG rendering capabilities for vector icons
- Qt Quick: QML rendering engine for UI
- File system: Read access to asset directories
- Configuration system: Theme selection from config files

## Out of Scope

- Converting GTK CSS to QML styles (only color extraction, not full CSS translation)
- Animated icons or icon transitions beyond static SVG rendering
- Runtime theme switching without application restart
- Creating new themes beyond KlipperScreen's existing themes
- Modifying or enhancing KlipperScreen's original icons
- Icon editing or generation tools
- Asset bundling or compilation into application binary
- Network-based asset loading or CDN support
- Icon colorization or dynamic recoloring beyond theme definitions
- Font file bundling (using system fonts only)
- Asset versioning or update mechanisms
- Automatic asset synchronization with KlipperScreen repository updates
- Asset optimization or minification
- Alternative icon formats beyond SVG (PNG/JPG support is optional enhancement only)
