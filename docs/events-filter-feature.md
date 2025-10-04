# 运动员项目动态过滤功能

## 功能说明

当在运动员报名表单中选择性别时，报名项目列表会根据性别自动过滤，只显示对应性别可以参加的项目。

## 技术实现

### 1. Stimulus 控制器
位置：`app/javascript/controllers/events_controller.js`

**功能：**
- 监听性别选择变化
- 根据性别过滤项目
- 自动禁用/启用复选框
- 管理分类标题的显示/隐藏

**Targets：**
- `genderSelect`: 性别选择框
- `eventItem`: 每个项目的 label 元素
- `trackSection`: 径赛分类区域
- `fieldSection`: 田赛分类区域
- `notice`: 提示信息

### 2. 视图集成
位置：`app/views/athletes/_form.html.erb`

**关键点：**
- 表单使用 `data-controller="events"` 绑定 Stimulus 控制器
- 性别选择框使用 `data-events-target="genderSelect"` 和 `data-action="change->events#filterByGender"`
- 每个项目标签使用 `data-events-target="eventItem"` 并附带 `data-gender` 和 `data-event-type` 属性

### 3. 数据流
1. 用户选择性别 → 触发 `filterByGender()` 方法
2. 读取性别值 → 遍历所有项目
3. 比较项目性别与选中性别 → 显示匹配的项目
4. 对于不匹配的项目 → 隐藏并禁用复选框
5. 检查各分类是否有可见项目 → 动态显示/隐藏分类标题

## 用户体验

### 未选择性别时
- 所有项目隐藏
- 复选框被禁用
- 显示提示："请先选择性别以查看可报名项目"

### 选择性别后
- 只显示对应性别的项目
- 混合项目对所有性别可见
- 复选框可用
- 如果某个分类（径赛/田赛）没有可用项目，自动隐藏该分类

## 支持的性别类型
- 男
- 女
- 混合（对所有性别开放）

## 依赖
- Rails 8
- Stimulus 3.x
- Hotwired Turbo
