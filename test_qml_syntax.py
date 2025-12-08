#!/usr/bin/env python3
"""快速验证 QML 语法测试脚本"""

import sys
from PyQt6.QtCore import QUrl
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtWidgets import QApplication

def test_qml_file(qml_path):
    """测试单个 QML 文件是否有语法错误"""
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # 添加导入路径
    engine.addImportPath("qml")

    # 加载 QML 文件
    engine.load(QUrl.fromLocalFile(qml_path))

    # 检查错误
    if engine.rootObjects():
        print(f"✅ {qml_path} - 语法正确")
        return True
    else:
        print(f"❌ {qml_path} - 有错误:")
        for error in engine.errors():
            print(f"   {error.toString()}")
        return False

if __name__ == "__main__":
    # 测试关键文件
    files_to_test = [
        "qml/pages/JobStatusPage.qml",
        "qml/pages/MovePage.qml",
        "qml/pages/FilesPage.qml",
        "qml/components/CircularProgress.qml",
    ]

    all_ok = True
    for file in files_to_test:
        if not test_qml_file(file):
            all_ok = False

    if all_ok:
        print("\n✅ 所有文件语法检查通过!")
        sys.exit(0)
    else:
        print("\n❌ 部分文件有语法错误")
        sys.exit(1)
