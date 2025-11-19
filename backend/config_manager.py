#!/usr/bin/env python3
"""
配置管理器模块

此模块提供配置文件的加载、保存和访问功能。
支持点分隔的键名访问嵌套配置值（如 "printer.host"）。
"""

import json
import logging
from pathlib import Path
from typing import Dict, Any, Optional


class ConfigManager:
    """
    配置管理器类

    负责管理应用程序的配置文件，提供配置的加载、保存、
    读取和修改功能。配置以JSON格式存储。

    Attributes:
        config_file (Path): 配置文件路径
        config (Dict[str, Any]): 配置数据字典
        logger: 日志记录器

    Example:
        >>> config = ConfigManager("config.json")
        >>> host = config.get("printer.host", "localhost")
        >>> config.set("printer.port", 7125)
        >>> config.save()
    """

    def __init__(self, config_file: str = "config.json"):
        """
        初始化配置管理器

        Args:
            config_file: 配置文件路径，默认为 "config.json"
        """
        self.config_file = Path(config_file)
        self.config: Dict[str, Any] = {}
        self.logger = logging.getLogger(__name__)
        self.load()

    def load(self) -> bool:
        """
        从文件加载配置

        如果配置文件不存在，将创建默认配置并保存。

        Returns:
            bool: 成功返回 True，失败返回 False
        """
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    self.config = json.load(f)
                self.logger.info(f"配置已加载: {self.config_file}")
                return True
            else:
                self.logger.warning(f"配置文件不存在: {self.config_file}")
                self._create_default_config()
                return False
        except json.JSONDecodeError as e:
            self.logger.error(f"配置文件格式错误: {e}")
            return False
        except Exception as e:
            self.logger.error(f"加载配置失败: {e}")
            return False

    def save(self) -> bool:
        """
        保存配置到文件

        将当前配置以格式化的JSON形式写入文件。

        Returns:
            bool: 成功返回 True，失败返回 False
        """
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
            self.logger.info("配置已保存")
            return True
        except Exception as e:
            self.logger.error(f"保存配置失败: {e}")
            return False

    def get(self, key: str, default: Any = None) -> Any:
        """
        获取配置值

        支持使用点分隔的键名访问嵌套值，如 "printer.host"。
        如果键不存在，返回默认值。

        Args:
            key: 配置键名，支持点分隔的嵌套访问
            default: 默认值，当键不存在时返回

        Returns:
            配置值或默认值

        Example:
            >>> config.get("printer.host", "localhost")
            "192.168.200.209"
        """
        keys = key.split('.')
        value = self.config

        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
                if value is None:
                    return default
            else:
                return default

        return value if value is not None else default

    def set(self, key: str, value: Any) -> None:
        """
        设置配置值

        支持使用点分隔的键名设置嵌套值，如 "printer.host"。
        如果中间层级不存在，会自动创建。

        注意：此方法只修改内存中的配置，需要调用 save() 方法持久化。

        Args:
            key: 配置键名，支持点分隔的嵌套访问
            value: 要设置的值

        Example:
            >>> config.set("printer.host", "192.168.1.100")
            >>> config.set("ui.theme", "dark")
        """
        keys = key.split('.')
        config = self.config

        for k in keys[:-1]:
            if k not in config or not isinstance(config[k], dict):
                config[k] = {}
            config = config[k]

        config[keys[-1]] = value

    def _create_default_config(self):
        """创建默认配置"""
        self.config = {
            "printer": {
                "host": "192.168.200.209",
                "port": 7125,
                "name": "My 3D Printer"
            },
            "ui": {
                "theme": "dark",
                "language": "zh_CN",
                "width": 800,
                "height": 480,
                "fullscreen": False
            },
            "temperature": {
                "extruder_presets": [0, 180, 200, 220, 240, 260],
                "bed_presets": [0, 50, 60, 70, 80, 90]
            },
            "features": {
                "auto_connect": True,
                "show_webcam": False,
                "enable_sounds": False
            }
        }
        self.save()
        self.logger.info("已创建默认配置")
