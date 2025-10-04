# 运动会管理系统

一个功能完整的学校运动会管理平台，支持从运动员报名到赛事安排的全流程管理。

## ✨ 功能特性

### 核心功能

- 🏃 **运动员管理**
  - 手动添加或Excel批量导入
  - 自动生成运动员编号
  - 性别智能过滤报名项目
  - 完整的增删改查功能

- 📊 **赛事分组**
  - 径赛项目自动分组
  - 智能赛道分配（确保连续）
  - 接力项目特殊处理
  - 支持手动调整

- 📅 **日程管理**
  - 可视化日程安排
  - 时间和场地设置
  - 冲突检测提醒
  - 完整的编辑功能

- 📈 **数据总览**
  - 实时统计数据
  - 功能卡片导航
  - 完整日程展示
  - 快速跳转管理

### 界面设计

- 采用 DaisyUI 组件库，界面美观统一
- 响应式设计，支持各种屏幕尺寸
- 步骤条引导，流程清晰
- 卡片式布局，信息层次分明

## 🚀 快速开始

### 环境要求

- Ruby 3.4.5
- Rails 8.0.3
- SQLite3 2.7.4
- Node.js（用于前端资源编译）

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd athletics-app
```

2. **安装依赖**
```bash
bundle install
```

3. **数据库设置**
```bash
rails db:migrate
```

4. **加载示例数据（可选）**
```bash
rails db:seed
```

5. **启动服务器**
```bash
bin/dev
```

6. **访问应用**
打开浏览器访问 `http://localhost:3000`

## 📖 使用指南

### 基本流程

```
1. 创建运动会
   ↓
2. 添加参赛年级
   ↓
3. 登记运动员信息
   ├─ 手动添加
   └─ Excel批量导入
   ↓
4. 生成运动员编号
   ↓
5. 自动生成径赛分组
   ↓
6. 安排比赛日程
   ↓
7. 查看总览和导出
```

### 详细文档

- [用户使用指南](docs/user-guide.md) - 完整的功能说明和操作步骤
- [Excel导入指南](docs/excel-import-guide.md) - 批量导入格式和注意事项
- [数据库结构](docs/database-structure.md) - 系统数据模型说明

## 🗂️ 项目结构

```
athletics-app/
├── app/
│   ├── controllers/          # 控制器
│   │   ├── athletes_controller.rb
│   │   ├── competitions_controller.rb
│   │   ├── grades_controller.rb
│   │   ├── heats_controller.rb
│   │   └── schedules_controller.rb
│   ├── models/               # 模型
│   │   ├── athlete.rb
│   │   ├── competition.rb
│   │   ├── grade.rb
│   │   ├── klass.rb
│   │   ├── heat.rb
│   │   ├── lane.rb
│   │   └── schedule.rb
│   ├── views/                # 视图
│   │   ├── athletes/
│   │   ├── competitions/
│   │   ├── grades/
│   │   ├── heats/
│   │   └── schedules/
│   └── javascript/           # 前端脚本
│       └── controllers/
│           └── events_controller.js
├── config/
│   ├── routes.rb            # 路由配置
│   └── database.yml         # 数据库配置
├── db/
│   ├── migrate/             # 数据库迁移
│   ├── schema.rb            # 数据库架构
│   └── seeds.rb             # 示例数据
└── docs/                    # 文档
    ├── user-guide.md
    ├── excel-import-guide.md
    └── database-structure.md
```

## 💾 数据模型

### 核心实体关系

```
Competition (运动会)
  ├─ Grade (年级)
  │   └─ Klass (班级)
  │       └─ Athlete (运动员)
  ├─ CompetitionEvent (比赛项目)
  │   └─ Heat (分组)
  │       └─ Lane (赛道)
  │           └─ LaneAthlete (赛道运动员)
  └─ Schedule (日程)
```

### 主要功能模块

1. **层级结构**：Competition → Grade → Klass → Athlete
2. **项目分类**：Event (田赛/径赛) → CompetitionEvent
3. **分组系统**：Heat → Lane → LaneAthlete
4. **日程管理**：Schedule (关联到Heat)

详见：[数据库结构文档](docs/database-structure.md)

## 🔧 技术栈

### 后端
- **框架**: Rails 8.0
- **数据库**: SQLite3
- **身份验证**: BCrypt

### 前端
- **样式**: Tailwind CSS + DaisyUI
- **JavaScript**: Stimulus
- **Turbo**: Hotwire Turbo

### 其他工具
- **Excel解析**: Roo gem
- **测试**: Minitest
- **代码质量**: RuboCop

## 📊 主要功能实现

### 1. 自动生成编号
```ruby
# 按年级 → 班级 → 性别排序后生成001开始的编号
athletes.each_with_index do |athlete, index|
  athlete.update_column(:student_number, format("%03d", index + 1))
end
```

### 2. 智能分组算法
```ruby
# 径赛：每组最多6人，随机打乱，赛道连续
shuffled_athletes = athletes.shuffle
heat_count = (shuffled_athletes.count.to_f / max_lanes).ceil

# 接力：按班级分组，每队4人
athletes_by_klass.each do |klass, klass_athletes|
  # 为每个班级创建一个Heat，分配一个Lane，4名运动员
end
```

### 3. Excel批量导入
```ruby
# 支持.xls和.xlsx格式
spreadsheet = Roo::Spreadsheet.open(file.path)
# 逐行解析，自动创建班级，关联项目
```

## 🎯 未来规划

- [ ] 田赛项目分组功能
- [ ] 成绩录入模块
- [ ] 自动排名计算
- [ ] 秩序册PDF导出
- [ ] 成绩册PDF导出
- [ ] 工作人员管理
- [ ] 更复杂的冲突检测
- [ ] 拖拽式日程编排

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

1. Fork本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建Pull Request

## 📝 许可证

本项目采用 MIT 许可证。

## 👥 作者

- 初始开发: [Your Name]
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 致谢

- Rails团队提供的优秀框架
- DaisyUI提供的精美组件
- Roo gem提供的Excel解析功能

---

**最后更新**: 2025年10月4日  
**版本**: 1.0.0
