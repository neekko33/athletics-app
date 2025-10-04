# 运动会管理系统 - 数据库重构文档

## 概述

本文档描述了运动会管理系统的完整数据库结构，该结构经过重新设计以满足复杂的运动会管理需求。

## 核心设计理念

### 层级结构
```
运动会 (Competition)
  ├── 年级 (Grade)
  │   ├── 班级 (Klass)
  │   │   └── 运动员 (Athlete)
  │   └── 比赛组 (Heat) - 仅田赛
  ├── 比赛项目 (CompetitionEvent)
  │   ├── 比赛组 (Heat)
  │   │   └── 跑道 (Lane)
  │   │       └── 运动员 (LaneAthlete)
  │   ├── 日程 (Schedule)
  │   └── 工作人员 (CompetitionEventStaff)
  └── 工作人员 (Staff)
```

## 数据表详细说明

### 1. 运动会表 (competitions)
运动会的基本信息。

**字段：**
- `id`: 主键
- `name`: 运动会名称
- `start_date`: 开始日期
- `created_at`, `updated_at`: 时间戳

**关联：**
- has_many :grades (年级)
- has_many :klasses (班级，通过年级)
- has_many :athletes (运动员，通过班级)
- has_many :competition_events (比赛项目)
- has_many :staff (工作人员)

---

### 2. 年级表 (grades)
运动会下的年级分组。

**字段：**
- `id`: 主键
- `competition_id`: 外键 → competitions
- `name`: 年级名称（如"一年级"）
- `order`: 排序顺序
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition
- has_many :klasses (班级)
- has_many :athletes (通过班级)
- has_many :heats (田赛比赛组)

---

### 3. 班级表 (klasses)
年级下的班级分组。注意：使用 `Klass` 而不是 `Class` 以避免与 Ruby 保留字冲突。

**字段：**
- `id`: 主键
- `grade_id`: 外键 → grades
- `name`: 班级名称（如"1班"）
- `order`: 排序顺序
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :grade
- has_many :athletes (运动员)

**方法：**
- `full_name`: 返回完整名称（如"一年级1班"）

---

### 4. 运动员表 (athletes)
参赛运动员信息。

**字段：**
- `id`: 主键
- `klass_id`: 外键 → klasses
- `name`: 姓名
- `gender`: 性别（"男"/"女"）
- `student_number`: 学号
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :klass (班级)
- has_one :grade (通过班级)
- has_one :competition (通过年级)
- has_many :lane_athletes (跑道分配)
- has_many :lanes (通过lane_athletes)
- has_many :results (成绩记录)
- has_many :athlete_competition_events (报名记录)
- has_many :competition_events (报名项目)

---

### 5. 项目表 (events)
所有可用的比赛项目。

**字段：**
- `id`: 主键
- `name`: 项目名称
- `event_type`: 项目类型（"track"径赛/"field"田赛）
- `gender`: 性别限制（"男"/"女"/"混合"）
- `max_participants`: 最大参赛人数
- `avg_time`: 平均耗时（分钟）
- `created_at`, `updated_at`: 时间戳

**关联：**
- has_many :competition_events
- has_many :competitions (通过competition_events)

---

### 6. 比赛项目表 (competition_events)
运动会中实际开展的比赛项目。

**字段：**
- `id`: 主键
- `competition_id`: 外键 → competitions
- `event_id`: 外键 → events
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition
- belongs_to :event
- has_many :heats (比赛组)
- has_many :athlete_competition_events (报名记录)
- has_many :athletes (通过athlete_competition_events)
- has_one :schedule (日程)
- has_many :competition_event_staff (工作人员分配)
- has_many :staff (通过competition_event_staff)

**方法：**
- `field_event?`: 是否田赛
- `track_event?`: 是否径赛
- `relay?`: 是否接力项目

---

### 7. 比赛组表 (heats)
比赛的分组信息。田赛按年级分组，径赛按报名顺序分组。

**字段：**
- `id`: 主键
- `competition_event_id`: 外键 → competition_events
- `grade_id`: 外键 → grades（径赛为null）
- `heat_number`: 组号
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition_event
- belongs_to :grade (optional: true，径赛不需要)
- has_many :lanes (跑道/位置)
- has_many :athletes (通过lanes)

**验证：**
- 田赛项目必须有 grade_id
- 径赛项目 grade_id 为 null

**方法：**
- `field_event?`: 是否田赛
- `track_event?`: 是否径赛
- `name`: 返回组名（如"一年级 - 第1组"或"第1组"）

---

### 8. 跑道/位置表 (lanes)
比赛组中的具体跑道或位置。

**字段：**
- `id`: 主键
- `heat_id`: 外键 → heats
- `lane_number`: 跑道号/位置号
- `position`: 位置顺序
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :heat
- has_many :lane_athletes (运动员分配，支持接力）
- has_many :athletes (通过lane_athletes)
- has_many :results (成绩记录)

**验证：**
- 同一heat中lane_number唯一

**方法：**
- `relay?`: 是否接力项目
- `valid_relay_team?`: 接力队是否有效（4人）

---

### 9. 跑道运动员关联表 (lane_athletes)
将运动员分配到具体跑道，支持接力项目（4人/道）。

**字段：**
- `id`: 主键
- `lane_id`: 外键 → lanes
- `athlete_id`: 外键 → athletes
- `relay_position`: 接力棒次（1-4），非接力为null
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :lane
- belongs_to :athlete

**验证：**
- 同一lane中athlete_id唯一
- 接力项目中同一lane的relay_position唯一
- relay_position 范围1-4

---

### 10. 工作人员表 (staffs)
运动会的工作人员。

**字段：**
- `id`: 主键
- `competition_id`: 外键 → competitions
- `name`: 姓名
- `role`: 角色类型
  - judge: 裁判
  - timer: 计时员
  - recorder: 记录员
  - coordinator: 协调员
  - medical: 医务人员
  - security: 安保人员
  - other: 其他
- `contact`: 联系方式
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition
- has_many :competition_event_staff
- has_many :competition_events (通过competition_event_staff)

---

### 11. 比赛项目工作人员关联表 (competition_event_staffs)
为具体比赛项目分配工作人员及其角色。

**字段：**
- `id`: 主键
- `competition_event_id`: 外键 → competition_events
- `staff_id`: 外键 → staffs
- `role_type`: 在该项目中的角色
  - chief_judge: 主裁判
  - judge: 裁判
  - timer: 计时员
  - recorder: 记录员
  - starter: 发令员
  - announcer: 播音员
  - other: 其他
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition_event
- belongs_to :staff

---

### 12. 日程表 (schedules)
比赛项目的时间安排。

**字段：**
- `id`: 主键
- `competition_event_id`: 外键 → competition_events
- `scheduled_at`: 计划开始时间
- `end_at`: 计划结束时间（自动计算）
- `venue`: 比赛场地
- `duration`: 预计时长（分钟）
- `status`: 状态
  - pending: 待进行
  - in_progress: 进行中
  - completed: 已完成
  - cancelled: 已取消
- `notes`: 备注
- `display_order`: 显示顺序
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :competition_event

**方法：**
- `calculate_end_at`: 自动计算结束时间
- `conflicts_with?`: 检查时间冲突
- `conflicting?`: 当前日程是否冲突

---

### 13. 成绩表 (results)
记录运动员在比赛中的成绩。

**字段：**
- `id`: 主键
- `lane_id`: 外键 → lanes
- `athlete_id`: 外键 → athletes
- `result_value`: 成绩值（秒或米）
- `rank`: 名次
- `status`: 状态
  - pending: 待录入
  - finished: 已完成
  - disqualified: 犯规
- `notes`: 备注（如犯规原因）
- `created_at`, `updated_at`: 时间戳

**关联：**
- belongs_to :lane
- belongs_to :athlete

**索引：**
- `[lane_id, athlete_id]`: 唯一索引
- `rank`: 索引

**方法：**
- `calculate_ranks_for_heat(heat)`: 自动计算某组的排名

---

## 数据流程示例

### 1. 创建运动会
```ruby
competition = Competition.create!(name: "2025年秋季运动会", start_date: Date.today)
```

### 2. 添加年级和班级
```ruby
grade = competition.grades.create!(name: "一年级", order: 1)
klass = grade.klasses.create!(name: "1班", order: 1)
```

### 3. 添加运动员
```ruby
athlete = klass.athletes.create!(
  name: "张三",
  gender: "男",
  student_number: "0101001"
)
```

### 4. 添加比赛项目
```ruby
event = Event.find_by(name: "100米", gender: "男")
comp_event = competition.competition_events.create!(event: event)
```

### 5. 创建日程
```ruby
comp_event.create_schedule!(
  scheduled_at: competition.start_date.to_time + 9.hours,
  venue: "田径场A",
  duration: 30,
  status: "pending"
)
```

### 6. 田赛分组（按年级）
```ruby
# 为每个年级创建比赛组
competition.grades.each_with_index do |grade, index|
  heat = comp_event.heats.create!(
    grade: grade,
    heat_number: index + 1
  )
  
  # 创建跑道
  (1..6).each do |lane_num|
    heat.lanes.create!(lane_number: lane_num, position: lane_num)
  end
end
```

### 7. 径赛分组（按报名顺序）
```ruby
# 获取所有报名的运动员
athletes = comp_event.athletes.order(:created_at)

# 每6人一组
athletes.in_groups_of(6, false).each_with_index do |group, index|
  heat = comp_event.heats.create!(
    heat_number: index + 1,
    grade: nil  # 径赛不需要年级
  )
  
  group.each_with_index do |athlete, lane_num|
    lane = heat.lanes.create!(lane_number: lane_num + 1, position: lane_num + 1)
    lane.lane_athletes.create!(athlete: athlete)
  end
end
```

### 8. 接力项目分组
```ruby
# 假设每个班级一个接力队
competition.klasses.each_with_index do |klass, index|
  heat = comp_event.heats.find_or_create_by!(heat_number: index + 1)
  lane = heat.lanes.create!(lane_number: index + 1, position: index + 1)
  
  # 为该班级的4名运动员分配棒次
  klass.athletes.limit(4).each_with_index do |athlete, position|
    lane.lane_athletes.create!(
      athlete: athlete,
      relay_position: position + 1
    )
  end
end
```

### 9. 分配工作人员
```ruby
judge = competition.staff.create!(
  name: "李裁判",
  role: "judge",
  contact: "13800138000"
)

comp_event.competition_event_staff.create!(
  staff: judge,
  role_type: "chief_judge"
)
```

### 10. 录入成绩
```ruby
lane = heat.lanes.first
athlete = lane.athletes.first

Result.create!(
  lane: lane,
  athlete: athlete,
  result_value: 12.5,  # 12.5秒
  status: "finished"
)

# 自动计算排名
Result.calculate_ranks_for_heat(heat)
```

---

## 关键特性

### 1. 田赛vs径赛的处理
- **田赛**：按年级分组，每组独立比赛
- **径赛**：不分年级，按报名顺序分组

### 2. 接力项目支持
- 通过 `lane_athletes` 表的 `relay_position` 字段支持
- 一个跑道可以关联4个运动员
- 验证确保每个跑道恰好4人

### 3. 日程冲突检测
- `Schedule.conflicts_with?` 方法检查时间和场地冲突
- 自动计算结束时间

### 4. 成绩管理
- 支持自动排名计算
- 记录犯规状态
- 可添加备注说明

### 5. 工作人员管理
- 双重角色系统：全局角色和项目角色
- 灵活分配工作人员到不同项目

---

## 数据统计查询示例

```ruby
# 运动会总览
competition = Competition.first
puts "参赛年级: #{competition.grades.count}"
puts "参赛班级: #{competition.klasses.count}"
puts "参赛运动员: #{competition.athletes.count}"
puts "比赛项目: #{competition.competition_events.count}"

# 某个项目的参赛情况
comp_event = CompetitionEvent.first
puts "报名人数: #{comp_event.athletes.count}"
puts "分组数: #{comp_event.heats.count}"

# 某个运动员的报名项目
athlete = Athlete.first
puts "#{athlete.name}报名的项目:"
athlete.events.each do |event|
  puts "- #{event.name}"
end

# 某个年级的参赛统计
grade = Grade.first
puts "#{grade.name}:"
puts "  班级数: #{grade.klasses.count}"
puts "  运动员数: #{grade.athletes.count}"
puts "  参与的田赛组数: #{grade.heats.count}"
```

---

## 下一步开发建议

1. **前端界面**
   - 拖拽式日程安排（使用FullCalendar或类似库）
   - 分组自动生成工具
   - 成绩录入界面

2. **业务逻辑**
   - 自动分组算法优化
   - 冲突检测和提醒
   - 报名限制和验证

3. **报表功能**
   - 成绩单打印
   - 参赛证生成
   - 统计报表

4. **实时功能**
   - 比赛进度实时更新
   - 成绩即时发布
   - 现场大屏显示

---

## 附录：完整模型关联图

```
Competition
├── grades → Grade
│   ├── klasses → Klass
│   │   └── athletes → Athlete
│   └── heats → Heat (田赛)
├── competition_events → CompetitionEvent
│   ├── heats → Heat
│   │   └── lanes → Lane
│   │       ├── lane_athletes → LaneAthlete
│   │       │   └── athlete → Athlete
│   │       └── results → Result
│   ├── schedule → Schedule
│   └── competition_event_staffs → CompetitionEventStaff
│       └── staff → Staff
└── staffs → Staff

Event
└── competition_events → CompetitionEvent
```

---

**文档版本**: 1.0  
**最后更新**: 2025年10月4日  
**维护者**: Athletics App Team
