# QtKs Development Guidelines

Auto-generated from all feature plans. Last updated: 2025-11-27

## Active Technologies

- (001-global-nav)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for 

## Code Style

: Follow standard conventions

## Recent Changes

- 001-global-nav: Added

## Deployment Scripts Status

### ⚠️ 未验证的脚本

以下脚本已创建但**尚未在实际环境中验证**，使用前请谨慎：

- **install.sh** - 自动化安装脚本
  - 功能：一键安装所有依赖、配置环境、设置自启动
  - 状态：❌ 未验证
  - 待验证内容：
    - 依赖安装是否完整
    - 虚拟环境创建是否成功
    - systemd 服务配置是否正确
    - 多平台兼容性（Orange Pi / Raspberry Pi）

- **setup-autostart.sh** - 开机自启动配置脚本
  - 功能：快速配置 systemd 服务和开机自启动
  - 状态：❌ 未验证
  - 待验证内容：
    - systemd 服务是否能正常启动
    - 不同 Qt 平台（xcb/wayland/eglfs）是否都能运行
    - 重启后是否自动启动

- **qtks.service.template** - systemd 服务模板
  - 功能：手动配置时的参考模板
  - 状态：❌ 未验证

### ✅ 已验证的部署方法

- 手动安装依赖（包括 libxcb-cursor0）- 已在 Orange Pi 上验证可行

### 验证检查清单

验证时请检查：
- [ ] install.sh 在 Orange Pi 上运行无错误
- [ ] 所有依赖安装成功
- [ ] Python 虚拟环境创建成功
- [ ] main.py 能正常启动
- [ ] systemd 服务能正常启动和停止
- [ ] 重启后服务自动启动
- [ ] 日志输出正常（journalctl -u qtks.service）

验证完成后，请更新此文档，将脚本状态改为 ✅ 已验证。

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
