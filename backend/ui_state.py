"""
UI State Management Module

Manages global UI state including page navigation, screensaver,
and idle timer for the QtKs application.
"""

import logging
from typing import Optional
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer, QEvent
from PySide6.QtWidgets import QApplication

logger = logging.getLogger(__name__)


class UIState(QObject):
    """
    Manages UI state for the Metro interface.

    Handles page navigation, screensaver activation, and user idle detection.
    """

    # Signals
    pageChanged = Signal(str)                    # Emitted when current page changes
    screensaverActiveChanged = Signal(bool)      # Emitted when screensaver state changes

    def __init__(self, parent=None):
        super().__init__(parent)

        # Page navigation state
        self._current_page = "home"
        self._screensaver_active = False

        # Idle detection timer
        self._idle_timer = QTimer()
        self._idle_timer.timeout.connect(self._on_idle_timeout)
        self._idle_interval = 300000  # 5 minutes default (in milliseconds)
        self._last_interaction_time = 0

        # Install event filter for idle detection
        self._install_event_filter()

        logger.info("UI State manager initialized")

    # Properties
    @Property(str, notify=pageChanged)
    def currentPage(self) -> str:
        """Current page name."""
        return self._current_page

    @Property(bool, notify=screensaverActiveChanged)
    def screensaverActive(self) -> bool:
        """Whether screensaver is currently active."""
        return self._screensaver_active

    @Property(bool, notify=pageChanged)
    def bottomNavVisible(self) -> bool:
        """Whether bottom navigation should be visible."""
        # Hide nav in printing and screensaver modes
        return not self._screensaver_active and self._current_page not in ["printing"]

    # Slots
    @Slot(str)
    def changePage(self, page_name: str):
        """Change current page."""
        valid_pages = ["home", "control", "files", "settings", "printing", "screensaver"]

        if page_name not in valid_pages:
            logger.warning(f"Invalid page name: {page_name}")
            return

        if page_name == self._current_page:
            return

        old_page = self._current_page
        self._current_page = page_name

        # Reset idle timer on page change
        self._reset_idle_timer()

        logger.info(f"Page changed: {old_page} -> {page_name}")
        self.pageChanged.emit(page_name)

    @Slot()
    def deactivateScreensaver(self):
        """Deactivate screensaver and return to home."""
        if self._screensaver_active:
            self._screensaver_active = False
            self.screensaverActiveChanged.emit(False)
            self.changePage("home")
            self._reset_idle_timer()
            logger.info("Screensaver deactivated")

    @Slot(int)
    def setScreensaverTimeout(self, timeout_ms: int):
        """Set screensaver timeout in milliseconds."""
        # Validate range: 1 minute to 1 hour
        if timeout_ms < 60000 or timeout_ms > 3600000:
            logger.warning(f"Invalid screensaver timeout: {timeout_ms}ms")
            return

        self._idle_interval = timeout_ms
        self._reset_idle_timer()
        logger.info(f"Screensaver timeout set to {timeout_ms}ms")

    # Public methods
    def start_idle_detection(self):
        """Start idle detection timer."""
        if not self._idle_timer.isActive():
            self._idle_timer.start(self._idle_interval)
            logger.info(f"Idle detection started with {self._idle_interval}ms timeout")

    def stop_idle_detection(self):
        """Stop idle detection timer."""
        if self._idle_timer.isActive():
            self._idle_timer.stop()
            logger.info("Idle detection stopped")

    # Private methods
    def _install_event_filter(self):
        """Install event filter for idle detection."""
        app = QApplication.instance()
        if app:
            app.installEventFilter(self)
            logger.debug("Event filter installed for idle detection")

    def _reset_idle_timer(self):
        """Reset idle timer on user interaction."""
        if not self._screensaver_active:
            self._last_interaction_time = 0
            if self._idle_timer.isActive():
                self._idle_timer.stop()
                self._idle_timer.start(self._idle_interval)

    def _on_idle_timeout(self):
        """Handle idle timeout."""
        if not self._screensaver_active:
            logger.info("Idle timeout reached, activating screensaver")
            self._screensaver_active = True
            self.screensaverActiveChanged.emit(True)
            # Note: Page switching to screensaver is handled by MainWindow

    def eventFilter(self, obj, event):
        """Filter events for idle detection."""
        # Consider these as user interactions
        interaction_events = [
            QEvent.MouseButtonPress,
            QEvent.MouseButtonRelease,
            QEvent.MouseMove,
            QEvent.KeyPress,
            QEvent.KeyRelease,
            QEvent.TouchBegin,
            QEvent.TouchUpdate,
            QEvent.TouchEnd,
            QEvent.Wheel,
        ]

        if event.type() in interaction_events:
            self._reset_idle_timer()

        return super().eventFilter(obj, event)

    def logPageChange(self, from_page: str, to_page: str, trigger: str = "user"):
        """Log page changes for analytics."""
        logger.info(f"Page navigation: {from_page} -> {to_page} (trigger: {trigger})")