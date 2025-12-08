# Configuration Loader for QtKs
# 配置加载器 - 从 config.json 加载主题配置
"""
ConfigLoader handles loading and validating theme configuration from config.json.

配置加载器处理从 config.json 加载和验证主题配置。
"""

import json
from pathlib import Path
from typing import Optional
import logging

from .models.theme_config import ThemeConfiguration

logger = logging.getLogger(__name__)


class ConfigLoadError(Exception):
    """配置加载失败 / Configuration loading failed"""
    pass


def load_theme_config(config_path: str = "config.json") -> ThemeConfiguration:
    """
    Load theme configuration from config.json.
    从 config.json 加载主题配置。

    Args:
        config_path (str): Path to configuration file

    Returns:
        ThemeConfiguration: Loaded and validated theme configuration

    Raises:
        ConfigLoadError: If configuration file cannot be loaded or is invalid
        FileNotFoundError: If configuration file doesn't exist
    """
    config_file = Path(config_path)

    if not config_file.exists():
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    try:
        with open(config_file, 'r', encoding='utf-8') as f:
            config = json.load(f)

        logger.debug(f"Loaded configuration from: {config_path}")

        # Create ThemeConfiguration from config dictionary
        theme_config = ThemeConfiguration.from_dict(config)

        # Validate that theme directory exists
        if not theme_config.theme_dir_path.exists():
            logger.warning(
                f"Theme directory does not exist: {theme_config.theme_dir_path}"
            )

        # Validate that selected theme exists
        selected_theme_path = theme_config.get_theme_path(theme_config.selected_theme)
        if not selected_theme_path.exists():
            logger.error(
                f"Selected theme directory not found: {selected_theme_path}"
            )
            raise ConfigLoadError(
                f"Selected theme '{theme_config.selected_theme}' not found at "
                f"{selected_theme_path}"
            )

        logger.info(f"Theme configuration loaded: {theme_config.selected_theme}")
        return theme_config

    except json.JSONDecodeError as e:
        raise ConfigLoadError(f"Invalid JSON in configuration file: {e}") from e
    except Exception as e:
        raise ConfigLoadError(f"Failed to load theme configuration: {e}") from e


def save_theme_config(
    theme_config: ThemeConfiguration,
    config_path: str = "config.json"
) -> None:
    """
    Save theme configuration to config.json.
    保存主题配置到 config.json。

    Args:
        theme_config (ThemeConfiguration): Theme configuration to save
        config_path (str): Path to configuration file

    Raises:
        ConfigLoadError: If configuration cannot be saved
    """
    config_file = Path(config_path)

    try:
        # Load existing config
        if config_file.exists():
            with open(config_file, 'r', encoding='utf-8') as f:
                config = json.load(f)
        else:
            config = {}

        # Update theme section
        config['theme'] = {
            'selected_theme': theme_config.selected_theme,
            'theme_dir': theme_config.theme_dir,
            'fallback_theme': theme_config.fallback_theme,
            'custom_icons_enabled': theme_config.custom_icons_enabled,
            'custom_icons_dir': theme_config.custom_icons_dir
        }

        # Write back
        with open(config_file, 'w', encoding='utf-8') as f:
            json.dump(config, f, indent=2, ensure_ascii=False)

        logger.info(f"Theme configuration saved: {theme_config.selected_theme}")

    except Exception as e:
        raise ConfigLoadError(f"Failed to save theme configuration: {e}") from e
