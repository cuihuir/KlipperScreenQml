# 导航测试验证清单

## 测试目的
验证 Control → Move 合并后的导航是否正常工作

## 测试步骤

### 1. 启动应用
```bash
python3 main.py
```

### 2. 测试 HomePage → Control
- [ ] 点击 HomePage 的 "Control" 功能图标
- [ ] 验证跳转到 MovePage
- [ ] 验证 MovePage 显示正常 (位置显示、移动按钮、挤出按钮)

### 3. 测试 JobStatusPage → Control
- [ ] 在打印过程中点击 PrintControlWidget 进入 JobStatusPage
- [ ] 点击 "控制" 按钮
- [ ] 验证跳转到 MovePage
- [ ] 验证可以返回到 JobStatusPage (RETURN 按钮)

### 4. 测试 MovePage 功能
- [ ] 测试 XY 移动按钮 (需要先归零)
- [ ] 测试 Z 轴移动按钮 (需要先归零)
- [ ] 测试 HOME 按钮 (全部归零)
- [ ] 测试 Z HOME 按钮 (Z 轴归零)
- [ ] 测试 EXTRUDE 按钮 (进料)
- [ ] 测试 RETRACT 按钮 (退料)
- [ ] 验证位置实时更新

### 5. 测试导航按钮
- [ ] 测试 HOME 按钮 (返回主页)
- [ ] 测试 RETURN 按钮 (返回上一页)

## 预期结果

✅ 所有 "control" 路由都指向 MovePage
✅ MovePage 功能完整,界面美观
✅ 导航逻辑正确,可以正常前进/后退

## 实际结果

填写测试结果...
