#!/usr/bin/env python3
"""Test JobStatusPage"""

import sys
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)

    engine = QQmlApplicationEngine()
    engine.load("test_job_status.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
