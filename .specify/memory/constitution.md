<!--
Sync Impact Report:
Version change: 1.0.0 → 1.1.0 (Touch target optimization for 11.3" screen)
Updated principles: Touch-First Design (80px targets for 11.3" 207 PPI screen)
Templates requiring updates: ✅ updated (plan.md, spec.md, tasks.md)
Follow-up TODOs: Add touch target validation tasks for 11.3" screen compatibility
Screen specifications: 11.3" diagonal, 1920×440 pixels, ~207 PPI, 4.36:1 aspect ratio
-->

# QtKs Constitution

## Core Principles

### I. Touch-First Design (NON-NEGOTIABLE)
所有交互必须为触摸屏优化。按钮和控件必须足够大以适应手指操作（最小触摸目标：80px×80px，约10mm物理尺寸，适配11.3寸207 PPI屏幕），禁用复杂的触摸手势（双击、长按、右键），确保单次点击即可完成所有操作。界面元素间距必须足够避免误触。

### II. Component Architecture
模块化组件设计，每个QML组件在qmldir中注册，可独立复用和测试。Python后端通过@Property/@Slot暴露接口，使用信号槽模式进行通信。新增页面不修改现有功能，保持向后兼容性。

### III. Real-Time Data Integrity
所有显示数据必须实时更新，温度、位置、进度等关键数据通过WebSocket获取，数据刷新延迟不超过2秒。UI状态与打印机状态保持同步，禁止显示过时信息。

### IV. API Integration Consistency
严格遵循Moonraker API协议，不修改或绕过标准接口。REST API用于同步操作，WebSocket用于实时数据。配置格式向后兼容，确保与不同版本的Klipper/Moonraker兼容。

### V. UI Design Specification Adherence
严格遵循ui_design目录中的设计图规范：纯黑背景(#000000)、亮黄强调色(#FFEB3B)、扁平设计、等宽数字、最小圆角。所有组件必须符合1920×440超宽屏布局规范，视觉设计必须与设计图保持95%以上的一致性。

## Touch Interface Constraints

### Touch Target Requirements
- **最小尺寸**: 80px×80px (约10mm×10mm物理尺寸，适配11.3寸207 PPI屏幕)
- **间距要求**: 相邻控件最小12px间距（避免误触）
- **禁用操作**: 双击、右键、长按、复杂手势
- **操作模式**: 单次点击完成所有交互
- **响应时间**: 触摸反馈<100ms
- **屏幕适配**: 基于11.3寸屏幕物理尺寸计算，确保触摸目标可操作

### Visual Feedback Standards
- **按下状态**: 颜色变化或透明度调整
- **禁用状态**: 明确的视觉区分(灰度/透明度)
- **加载状态**: 进度指示器或加载动画
- **错误状态**: 错误色彩和明确提示信息

### Accessibility Requirements
- **对比度**: 至少4.5:1的文本对比度
- **字体大小**: 最小20px可读字体（适配207 PPI高密度屏）
- **色彩区分**: 不仅依赖颜色传达状态
- **操作提示**: 明确的操作指示和状态反馈
- **屏幕密度**: 针对11.3寸207 PPI屏优化字体和间距

## Performance Requirements

### Response Time Standards
- **页面切换**: <300ms
- **数据更新**: <2s
- **触摸响应**: <100ms
- **文件列表渲染**: <500ms (100项)

### Resource Constraints
- **内存使用**: <200MB (嵌入式环境)
- **CPU占用**: <15% (活动状态)
- **离线能力**: 核心功能无需网络

## Development Workflow

### Code Quality Standards
- **架构分离**: backend/ (Python) + qml/ (QML) 严格分离
- **组件注册**: 所有QML组件在qmldir中正确注册
- **信号槽通信**: Python后端通过@Property/@Slot暴露接口
- **配置管理**: 使用ConfigManager进行设置持久化

### Testing Requirements
- **触摸测试**: 验证所有控件符合触摸目标要求
- **响应测试**: 验证页面切换和数据更新时间
- **兼容测试**: 验证与不同版本Klipper/Moonraker的兼容性
- **集成测试**: 验证完整打印工作流程

### Review Process
- **代码审查**: 所有PR必须验证宪法合规性
- **设计审查**: UI设计必须符合ui_design目录中的设计图规范
- **性能审查**: 必须满足响应时间和资源约束
- **测试审查**: 必须通过所有必需测试用例

## Governance

### Constitution Authority
本宪章优先级高于所有其他实践和约定。所有开发活动必须符合宪章规定，如有冲突以宪章为准。

### Amendment Process
- **MAJOR版本**: 向后不兼容的治理原则删除或重新定义
- **MINOR版本**: 新增原则或部分实质性扩展（如屏幕适配优化）
- **PATCH版本**: 澄清、措辞、拼写修复等非语义优化
- **要求**: 所有修订需要文档记录、批准和迁移计划

### Compliance Review
- **强制审查**: 所有PR必须验证宪章合规性
- **复杂度验证**: 任何设计选择必须证明其合理性
- **文档维护**: 运行时开发指南必须与宪章保持一致
- **版本追踪**: 宪章版本变更必须记录在Sync Impact Report

**Version**: 1.1.0 | **Ratified**: 2025-11-20 | **Last Amended**: 2025-11-23