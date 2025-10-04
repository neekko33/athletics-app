# 通知系统优化说明

## ✅ 已完成的改进

### 1. 修复 grade_id NOT NULL 约束问题

**问题**：径赛分组时出现 `SQLite3::ConstraintException: NOT NULL constraint failed: heats.grade_id` 错误

**原因**：
- 模型中设置了 `belongs_to :grade, optional: true`（径赛不需要年级分组）
- 但数据库中 `grade_id` 字段有 `NOT NULL` 约束

**解决方案**：
- 创建迁移 `ChangeGradeIdToNullableInHeats`
- 修改 `heats.grade_id` 允许为 NULL
- 现在径赛分组可以正常创建（grade_id = nil）

### 2. DaisyUI Toast 通知系统

**实现内容**：

#### 新增文件：
- `app/helpers/flash_helper.rb` - Flash 消息样式和图标助手
- `app/views/shared/_flash.html.erb` - 统一的 Flash 消息组件

#### 功能特性：
- ✅ 使用 DaisyUI 的 Alert 组件
- ✅ 右上角 Toast 提示（toast-top toast-end）
- ✅ 自动 5 秒后消失
- ✅ 手动关闭按钮
- ✅ 平滑滑入动画
- ✅ 四种消息类型：
  - `notice/success` - 成功提示（绿色，带✓图标）
  - `alert/error` - 错误提示（红色，带✕图标）
  - `warning` - 警告提示（黄色，带⚠图标）
  - `info` - 信息提示（蓝色，带ℹ图标）

#### 更新的视图文件：
- `app/views/layouts/application.html.erb` - 引入 Flash partial
- `app/views/competitions/show.html.erb` - 移除旧 notice 代码
- `app/views/competitions/index.html.erb` - 移除旧 notice 代码
- `app/views/events/index.html.erb` - 移除旧 notice 代码

#### 更新的控制器：
- `competitions_controller.rb` - 中文化消息
- `events_controller.rb` - 中文化消息
- `athletes_controller.rb` - 添加错误处理和 flash[:alert]

## 使用示例

### 在控制器中使用：

```ruby
# 成功消息
redirect_to @resource, notice: "操作成功"

# 错误消息
redirect_to @resource, alert: "操作失败：原因说明"

# 警告消息
redirect_to @resource, flash: { warning: "注意事项" }

# 信息消息
redirect_to @resource, flash: { info: "提示信息" }

# 表单错误（使用 flash.now）
flash.now[:alert] = "表单验证失败：#{@model.errors.full_messages.join(', ')}"
render :edit, status: :unprocessable_entity
```

### 视图效果：

```
┌────────────────────────────────────┐
│ ✓ 运动员添加成功                    [×] │
└────────────────────────────────────┘
```

## 测试建议

1. **成功通知测试**：
   - 创建/编辑/删除运动会
   - 创建/编辑/删除运动员
   - 生成运动员编号
   - 生成径赛分组

2. **错误通知测试**：
   - 表单验证失败（空字段等）
   - 创建重复数据

3. **自动生成径赛分组**：
   - 确认不再出现 grade_id 错误
   - 验证分组正确创建

## 技术细节

### CSS 动画：
```css
@keyframes slide-in {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
```

### JavaScript 自动关闭：
```javascript
setTimeout(() => {
  // 5秒后淡出并移除
}, 5000);
```

### DaisyUI 类：
- `toast` - Toast 容器
- `toast-top toast-end` - 右上角定位
- `alert` - 警告框基础样式
- `alert-success/error/warning/info` - 不同类型样式
- `z-50` - 确保在顶层显示
