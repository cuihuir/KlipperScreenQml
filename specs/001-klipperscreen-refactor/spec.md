# Feature Specification: KlipperScreen Logic and Layout Refactor

**Feature Branch**: `001-klipperscreen-refactor`
**Created**: 2025-12-07
**Status**: Draft
**Input**: User description: "完全按照KlipperScreen的逻辑及页面布局重构一遍,我们只是用qml+pyside6引擎"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Main Menu Navigation and Layout (Priority: P1)

Users need a main menu interface that matches KlipperScreen's familiar layout, allowing them to access all printer functions through a consistent, intuitive interface while viewing critical temperature and status information at a glance.

**Why this priority**: This is the entry point for all user interactions and establishes the core navigation paradigm that all other features depend on. Without this, users cannot access any printer functions.

**Independent Test**: Can be fully tested by launching the application, verifying the main menu displays with temperature graphs, heater controls, and menu buttons matching KlipperScreen's layout, and confirms navigation to at least one panel works.

**Acceptance Scenarios**:

1. **Given** the application launches, **When** user views the main screen, **Then** they see a layout matching KlipperScreen's main menu with left panel (temperature graph and heater controls) and right panel (grid of menu buttons)
2. **Given** the main menu is displayed, **When** user observes the temperature graph, **Then** they see real-time temperature curves for all active heaters and temperature sensors
3. **Given** the main menu shows heater controls, **When** user clicks on a heater name, **Then** they can toggle its visibility on the temperature graph
4. **Given** the main menu shows heater controls, **When** user clicks on a heater temperature, **Then** a numeric keypad appears to set target temperature
5. **Given** menu buttons are displayed, **When** user taps any menu button, **Then** the corresponding panel opens with proper navigation stack

---

### User Story 2 - Panel System and Base Functionality (Priority: P1)

Users need all KlipperScreen panels (movement, extrusion, temperature, bed leveling, etc.) to function identically to the original, ensuring familiar workflows and muscle memory transfer from existing KlipperScreen installations.

**Why this priority**: This delivers the core 3D printer control functionality. Without functional panels, the interface is just a navigation shell with no practical value.

**Independent Test**: Can be tested by navigating to each panel type (move, extrude, temperature, bed level, fan, LED, macros, etc.), verifying layout matches KlipperScreen, and confirming basic interactions work (button presses, value changes).

**Acceptance Scenarios**:

1. **Given** user navigates to the Move panel, **When** viewing the interface, **Then** they see identical layout to KlipperScreen with axis controls, home buttons, and position display
2. **Given** user navigates to the Temperature panel, **When** viewing controls, **Then** they see all heaters with preset temperatures matching KlipperScreen's preset system
3. **Given** user navigates to the Extrude panel, **When** viewing controls, **Then** they see extruder selection, length controls, and speed settings identical to KlipperScreen
4. **Given** user navigates to any panel, **When** they view the action bar, **Then** they see back, home, emergency stop, and shutdown buttons in the same positions as KlipperScreen
5. **Given** user is on any panel, **When** they press the back button, **Then** they navigate to the previous panel maintaining the navigation stack

---

### User Story 3 - Title Bar and Status Display (Priority: P1)

Users need a persistent title bar showing current temperatures, time, battery status (if applicable), and panel title, matching KlipperScreen's information density and layout to maintain situational awareness.

**Why this priority**: Critical status information must be visible at all times regardless of which panel is active. This prevents thermal runaways and keeps users informed of system state.

**Independent Test**: Can be tested by observing the title bar across different panels, verifying temperature display updates, time displays correctly, and layout matches KlipperScreen's title bar structure.

**Acceptance Scenarios**:

1. **Given** any panel is displayed, **When** user views the title bar, **Then** they see current/target temperatures for active heaters, current time, and panel title
2. **Given** the title bar shows temperatures, **When** temperature values change, **Then** updates appear within 2 seconds matching KlipperScreen's update frequency
3. **Given** the title bar displays time, **When** user has configured 24-hour format, **Then** time displays in 24-hour format; otherwise 12-hour format with AM/PM
4. **Given** the system has battery information available, **When** viewing the title bar, **Then** battery level and charging status appear with appropriate icons

---

### User Story 4 - Printer State Management and Updates (Priority: P1)

Users need the interface to reflect real-time printer state changes (print progress, temperature changes, axis positions, etc.) with the same responsiveness and update frequency as KlipperScreen.

**Why this priority**: Real-time state updates are essential for safe printer operation. Delayed or missing updates could result in failed prints or safety issues.

**Independent Test**: Can be tested by starting a print job, moving axes, changing temperatures, and verifying all UI elements update within expected timeframes (typically 1-2 seconds for most values, 100ms for print progress).

**Acceptance Scenarios**:

1. **Given** a print is in progress, **When** viewing the job status panel, **Then** progress bar, time estimates, layer count, and thumbnails update matching KlipperScreen's display
2. **Given** temperatures are changing, **When** viewing any panel with temperature display, **Then** all temperature values update within 2 seconds
3. **Given** axes are moving, **When** viewing position displays, **Then** position coordinates update in real-time
4. **Given** the printer state changes (e.g., idle to printing, ready to error), **When** viewing the interface, **Then** appropriate status indicators and available actions update immediately

---

### User Story 5 - Configuration and Multi-Printer Support (Priority: P2)

Users need the ability to configure multiple printers, switch between them, and have settings persist across sessions, matching KlipperScreen's configuration file structure and multi-printer capabilities.

**Why this priority**: Many users manage multiple printers. While not essential for basic operation, multi-printer support significantly improves usability for advanced users.

**Independent Test**: Can be tested by configuring multiple printers in the config file, verifying the printer selection screen appears, and confirming settings persist after application restart.

**Acceptance Scenarios**:

1. **Given** multiple printers are configured, **When** application starts, **Then** user sees a printer selection screen matching KlipperScreen's layout
2. **Given** user selects a printer, **When** navigating the interface, **Then** all panels show data and controls specific to that printer
3. **Given** user is on the main menu, **When** multiple printers are configured, **Then** a printer switch button appears in the action bar
4. **Given** user changes settings (graph visibility, presets, etc.), **When** restarting the application, **Then** all settings are preserved

---

### User Story 6 - Dialogs and Prompts (Priority: P2)

Users need confirmation dialogs, keyboard input, numeric keypads, and other prompt types matching KlipperScreen's implementations for consistent interaction patterns.

**Why this priority**: Dialogs prevent accidental destructive actions and enable text/numeric input. Important for safety and usability, but basic panel navigation works without them.

**Independent Test**: Can be tested by triggering various dialogs (emergency stop confirmation, file deletion, keyboard input, numeric keypad) and verifying layout and behavior match KlipperScreen.

**Acceptance Scenarios**:

1. **Given** user initiates a destructive action (e.g., emergency stop, delete file), **When** the action is triggered, **Then** a confirmation dialog appears matching KlipperScreen's design
2. **Given** user needs to input text (e.g., rename file), **When** the input is required, **Then** an on-screen keyboard appears matching KlipperScreen's layout
3. **Given** user needs to input numbers (e.g., set temperature), **When** the input is required, **Then** a numeric keypad appears matching KlipperScreen's design
4. **Given** a dialog is displayed, **When** user confirms or cancels, **Then** the dialog closes and the appropriate action is executed or cancelled

---

### User Story 7 - Special Screens (Screensaver, Lock Screen, Splash) (Priority: P3)

Users need screensaver, lock screen, and splash screen functionality matching KlipperScreen's implementations to protect displays and provide startup feedback.

**Why this priority**: These features improve hardware longevity and user experience but are not essential for basic printer operation. Can be added after core functionality is complete.

**Independent Test**: Can be tested by configuring screensaver timeout, verifying screensaver activates after idle period, testing lock screen if enabled, and observing splash screen during startup.

**Acceptance Scenarios**:

1. **Given** screensaver is configured with a timeout, **When** no user interaction occurs for the timeout period, **Then** screensaver activates matching KlipperScreen's screensaver behavior
2. **Given** screensaver is active, **When** user touches the screen, **Then** screensaver deactivates and returns to the previous panel
3. **Given** lock screen is enabled, **When** screensaver deactivates, **Then** user must enter PIN before accessing the interface
4. **Given** application is starting, **When** loading is in progress, **Then** splash screen displays matching KlipperScreen's splash design

---

### Edge Cases

- What happens when Moonraker/Klipper connection is lost during operation? System should display connection error matching KlipperScreen's error handling, attempt reconnection, and restore state when connection returns
- How does the system handle printers with unusual configurations (multiple extruders, large numbers of temperature sensors, custom panels)? System should dynamically adapt layout like KlipperScreen does
- What happens when screen orientation or resolution changes? System should adapt layout for vertical/horizontal modes and different aspect ratios like KlipperScreen
- How does the system handle rapid state changes (fast temperature fluctuations, quick axis movements)? Updates should be throttled to match KlipperScreen's update frequency without overwhelming the UI
- What happens when required configuration files are missing or corrupted? System should fall back to defaults and display warnings matching KlipperScreen's behavior
- How does the system handle panels that don't exist in the configuration? System should skip unavailable panels and log warnings without crashing

## Requirements *(mandatory)*

### Functional Requirements

**Core Architecture**

- **FR-001**: System MUST implement a panel-based architecture where each panel inherits from a base panel class, matching KlipperScreen's panel hierarchy
- **FR-002**: System MUST support dynamic panel loading and unloading as users navigate between screens
- **FR-003**: System MUST maintain a navigation stack allowing users to return to previous panels via back button
- **FR-004**: System MUST separate UI logic (QML) from business logic (Python) following KlipperScreen's separation pattern
- **FR-005**: System MUST implement screen orientation detection and adapt layout for vertical and horizontal modes

**Main Menu Panel**

- **FR-006**: System MUST display a main menu with left panel containing temperature graph and heater controls (matching KlipperScreen's main_menu.py layout)
- **FR-007**: System MUST display menu items in a grid on the right side (or bottom in vertical mode) with icons and labels
- **FR-008**: System MUST show real-time temperature graph with curves for all visible heaters and sensors
- **FR-009**: System MUST allow users to toggle temperature curve visibility by clicking heater names
- **FR-010**: System MUST display current and target temperatures for all heaters in the left panel
- **FR-011**: System MUST show heater controls that open numeric keypads when clicked

**Panel System**

- **FR-012**: System MUST implement all KlipperScreen core panels: main_menu, move, extrude, temperature, fan, led, bed_level, bed_mesh, job_status, fine_tune, console, gcode_macros, settings, network, system, printer_select
- **FR-013**: System MUST implement base panel functionality including title bar, action bar, and content area
- **FR-014**: System MUST support panel activation/deactivation lifecycle methods
- **FR-015**: System MUST allow panels to register for printer state update callbacks
- **FR-016**: System MUST support custom panels defined in configuration files

**Action Bar**

- **FR-017**: System MUST display action bar with back, home, emergency stop, shutdown, and printer select buttons (matching base_panel.py)
- **FR-018**: System MUST position action bar on left side in horizontal mode, bottom in vertical mode
- **FR-019**: System MUST enable/disable action bar buttons based on navigation state and printer status
- **FR-020**: System MUST show emergency stop button only when printer is in operational state
- **FR-021**: System MUST show printer select button only when multiple printers are configured

**Title Bar**

- **FR-022**: System MUST display title bar with panel title, heater temperatures, time, and battery status (if available)
- **FR-023**: System MUST update title bar temperatures every 1-2 seconds matching printer state updates
- **FR-024**: System MUST display time in 24-hour or 12-hour format based on configuration
- **FR-025**: System MUST show condensed temperature information (icon + current/target temp) for each active heater
- **FR-026**: System MUST display battery level and charging status when running on battery-powered hardware

**Printer Communication**

- **FR-027**: System MUST connect to Moonraker API via WebSocket for real-time updates
- **FR-028**: System MUST use REST API for non-real-time operations (file uploads, configuration queries)
- **FR-029**: System MUST handle connection loss gracefully with automatic reconnection attempts
- **FR-030**: System MUST maintain printer state object mirroring Klipper's state (matching ks_includes/printer.py)
- **FR-031**: System MUST subscribe to printer object updates and trigger UI updates when state changes

**Configuration**

- **FR-032**: System MUST read configuration from KlipperScreen.conf or compatible format
- **FR-033**: System MUST support multiple printer configurations with unique connection parameters
- **FR-034**: System MUST persist user preferences (graph visibility, temperature presets, panel settings) per printer
- **FR-035**: System MUST support configuration overrides for panel behavior and appearance
- **FR-036**: System MUST validate configuration on startup and fall back to defaults for invalid values

**Dialogs and Widgets**

- **FR-037**: System MUST implement confirmation dialogs for destructive actions (emergency stop, file deletion, shutdown)
- **FR-038**: System MUST implement numeric keypad widget for temperature and numeric value input
- **FR-039**: System MUST implement on-screen keyboard widget for text input
- **FR-040**: System MUST implement screensaver with configurable timeout and display
- **FR-041**: System MUST implement lock screen with PIN entry when enabled in configuration
- **FR-042**: System MUST implement splash screen during application startup

**Print Job Management**

- **FR-043**: System MUST display job status panel showing print progress, elapsed/remaining time, layer count, and thumbnail
- **FR-044**: System MUST allow users to pause, resume, and cancel print jobs
- **FR-045**: System MUST display file browser panel for selecting G-code files to print
- **FR-046**: System MUST show file metadata including thumbnails, estimated time, filament usage
- **FR-047**: System MUST support file operations (print, delete, rename) matching KlipperScreen's file panel

**Heater Management**

- **FR-048**: System MUST support all heater types: extruders, heated bed, heater_generic, temperature_fan
- **FR-049**: System MUST allow setting target temperatures via numeric keypad
- **FR-050**: System MUST display temperature presets for quick selection
- **FR-051**: System MUST show heater power output on graph when configured
- **FR-052**: System MUST support cooldown action to set all heaters to 0

**Movement and Homing**

- **FR-053**: System MUST implement move panel with axis controls (X, Y, Z, and additional axes if configured)
- **FR-054**: System MUST provide multiple movement distance options (0.1mm, 1mm, 10mm, 25mm, 50mm)
- **FR-055**: System MUST support homing individual axes and all axes
- **FR-056**: System MUST display current position for all axes
- **FR-057**: System MUST implement Z offset adjustment controls (matching zcalibrate panel)

**Extrusion**

- **FR-058**: System MUST implement extrude panel with extruder selection (for multi-extruder setups)
- **FR-059**: System MUST provide extrusion length controls (5mm, 10mm, 25mm, custom)
- **FR-060**: System MUST provide extrusion speed controls
- **FR-061**: System MUST prevent extrusion when temperature is below minimum extrusion temperature
- **FR-062**: System MUST support retraction operations

**Bed Leveling and Mesh**

- **FR-063**: System MUST implement bed level panel for manual bed leveling procedures
- **FR-064**: System MUST implement bed mesh panel showing mesh visualization
- **FR-065**: System MUST support bed mesh calibration, loading, and saving operations
- **FR-066**: System MUST display bed mesh as 3D representation or heatmap (matching KlipperScreen's bedmap widget)

**Fans and LEDs**

- **FR-067**: System MUST implement fan panel showing all configured fans with speed controls
- **FR-068**: System MUST implement LED panel for controlling addressable LEDs (when configured)
- **FR-069**: System MUST support color selection and preset patterns for LEDs
- **FR-070**: System MUST display current fan speeds as percentages

**Macros and Console**

- **FR-071**: System MUST implement gcode macros panel displaying configured Klipper macros
- **FR-072**: System MUST allow executing macros with single tap
- **FR-073**: System MUST implement console panel for viewing printer output and sending manual commands
- **FR-074**: System MUST display console output in scrollable text area with timestamps

**Settings and System**

- **FR-075**: System MUST implement settings panel for configuring interface preferences
- **FR-076**: System MUST implement system panel for system operations (restart, update, etc.)
- **FR-077**: System MUST implement network panel for WiFi/network configuration
- **FR-078**: System MUST support firmware update operations through updater panel

**Visual Design**

- **FR-079**: System MUST use icon set matching or compatible with KlipperScreen's icons
- **FR-080**: System MUST implement theming support with dark mode as default
- **FR-081**: System MUST use font sizes and spacing matching KlipperScreen's visual hierarchy
- **FR-082**: System MUST support custom color schemes for temperature graphs
- **FR-083**: System MUST implement responsive layout adapting to different screen sizes (800x480 minimum, scales to larger)

### Key Entities *(include if feature involves data)*

- **Panel**: Represents a UI screen/page with lifecycle (activate, deactivate, process_update), content area, title, and navigation behavior
- **Printer**: Represents printer state including heaters, axes, fans, LEDs, print job status, configuration, and connection info
- **HeaterDevice**: Temperature device with current temperature, target temperature, power output, and device type (extruder, bed, generic, fan)
- **PrintJob**: Active print job with file name, thumbnail, progress percentage, elapsed time, remaining time, layer count, and state (printing, paused, complete)
- **GCodeFile**: Represents a G-code file with metadata including name, path, size, modified date, thumbnail, estimated print time, and filament usage
- **Configuration**: Application and printer configuration including connection parameters, UI preferences, panel settings, and user customizations
- **NavigationStack**: History of visited panels enabling back button navigation and maintaining panel state
- **MacroDefinition**: Klipper macro with name, description, icon, and parameters for execution
- **BedMesh**: Bed leveling mesh with probe points, Z values, and visualization data

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users familiar with KlipperScreen can navigate the interface without training, achieving 100% task completion rate for common operations (starting print, setting temperature, homing axes)
- **SC-002**: All panels render and become interactive within 500ms of navigation action
- **SC-003**: Temperature graph updates occur every 1-2 seconds with smooth curve rendering at 30fps minimum
- **SC-004**: System maintains connection to printer with 99.9% uptime during normal operation (excluding network failures)
- **SC-005**: Application startup time from launch to main menu display is under 3 seconds
- **SC-006**: Interface remains responsive during print jobs with all user interactions completing within 200ms
- **SC-007**: Memory usage remains stable under 200MB during extended operation (24+ hour print jobs)
- **SC-008**: Panel layouts match KlipperScreen reference screenshots with 95%+ visual similarity (allowing for QML vs GTK rendering differences)
- **SC-009**: All 15+ core panels are implemented and functional with feature parity to KlipperScreen equivalents
- **SC-010**: Configuration files from KlipperScreen are compatible with minimal or no modifications
- **SC-011**: Users can switch between multiple configured printers in under 3 seconds
- **SC-012**: Emergency stop action triggers within 100ms of button press for safety-critical responsiveness

## Assumptions

- Moonraker API compatibility: Assuming Moonraker API remains stable and compatible with KlipperScreen's current API usage patterns
- Hardware capabilities: Assuming target hardware (Orange Pi, Raspberry Pi) has sufficient CPU/GPU for QML rendering at 30fps minimum
- Display resolution: Assuming minimum display resolution of 800x480 (standard for 3D printer touchscreens), with support for higher resolutions
- Touch input: Assuming all interactions can be completed via touchscreen without requiring keyboard/mouse
- Network connectivity: Assuming stable local network connection between interface and printer (WiFi or Ethernet)
- Python version: Assuming Python 3.8+ is available on target systems
- PySide6 availability: Assuming PySide6 can be installed on target ARM-based hardware
- QML support: Assuming Qt 6.x QML engine performs adequately on embedded hardware
- File system access: Assuming read/write access to configuration directory and G-code file storage locations
- Klipper version: Assuming relatively recent Klipper installation (within past 1-2 years) with standard object model
- Default language: Assuming English as default with potential for localization later (KlipperScreen's i18n system is reference)
- Single user: Assuming single-user operation without multi-user authentication requirements
- Temperature update frequency: Moonraker provides temperature updates at 1-2 second intervals as default
- Preset temperatures: Standard PLA/PETG/ABS presets are industry-standard defaults (190-230°C extruder, 50-110°C bed)
- Movement distances: Standard movement increments (0.1, 1, 10, 25, 50mm) match common user preferences from KlipperScreen usage

## Dependencies

- KlipperScreen codebase: Reference implementation for all panel logic, layouts, and behavior
- Moonraker API: Backend API for printer communication and control
- Klipper firmware: 3D printer firmware providing printer state and accepting commands
- PySide6: Python bindings for Qt 6.x framework
- Qt 6.x: QML engine and UI framework
- QML Material style: Modern UI component library for consistent look and feel
- Local network: Connection between interface device and printer
- Configuration files: KlipperScreen.conf or compatible configuration format

## Out of Scope

- Custom widget implementations beyond QML standard components (will use QML equivalents instead of GTK widgets)
- Print file slicing or G-code generation (user provides pre-sliced files)
- Webcam/camera streaming (may be added in future iteration)
- Update/upgrade system for Klipper/Moonraker (system panel provides basic restart functionality only)
- Advanced customization UI for creating new panels (configuration file editing only)
- Multi-language support in initial version (English only, i18n system deferred to future version)
- Spoolman integration (filament management system - deferred to future version)
- Input shaper tuning interface (complex advanced feature - deferred)
- Power device control panel (shutdown/restart printer PSU - deferred)
- Notifications/alerts panel (beyond basic error dialogs - deferred)
- Graph data export or advanced analysis tools
- Remote access or cloud connectivity features
- Authentication/authorization beyond optional lock screen PIN
- Accessibility features (screen reader, high contrast, voice control)
- Animated transitions beyond basic QML state transitions
- Advanced theming beyond dark/light mode color schemes
