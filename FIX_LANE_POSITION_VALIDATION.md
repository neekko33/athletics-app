# 修复赛道 Position 验证问题

## 问题描述

自动生成径赛分组时出现错误：
```
ActiveRecord::RecordInvalid (Validation failed: Position can't be blank, Position is not a number)
```

## 问题原因

`Lane` 模型对 `position` 字段有强制验证要求：
```ruby
validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
```

但是：
- **径赛项目**使用 `lane_number`（赛道号）来标识位置，不需要 `position` 字段
- **田赛项目**使用 `position`（试跳/试投顺序）来标识位置，不需要 `lane_number` 字段

由于验证对所有项目类型都生效，导致创建径赛赛道时失败。

## 解决方案

修改 `app/models/lane.rb`，使 `position` 验证仅在田赛项目时生效：

### 修改前
```ruby
validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
```

### 修改后
```ruby
validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }, if: :field_event?

# 新增方法
def field_event?
  heat.competition_event.event.event_type == "field"
end
```

## 字段使用说明

### 径赛项目（Track Events）
- 使用 `lane_number`：表示赛道号（1-8）
- `position` 可以为 `nil`
- 示例：100米第1组，赛道3

### 田赛项目（Field Events）
- 使用 `position`：表示试跳/试投顺序（1-n）
- `lane_number` 仍然需要（用于分组）
- 示例：跳远第1组，第5位

## 验证测试

### 测试径赛赛道创建
```ruby
track_event = competition.competition_events.joins(:event)
                         .where(events: { event_type: 'track' }).first
heat = track_event.heats.create!(heat_number: 1, total_lanes: 8)
lane = heat.lanes.create!(lane_number: 1)  # ✓ position 可以为 nil
```

### 测试田赛赛道创建
```ruby
field_event = competition.competition_events.joins(:event)
                         .where(events: { event_type: 'field' }).first
heat = field_event.heats.create!(heat_number: 1, grade_id: 1)
lane = heat.lanes.create!(lane_number: 1, position: 1)  # ✓ position 必填
```

## 测试结果

自动生成径赛分组测试：
```
找到 10 个径赛项目

处理项目: 400米 (8 人)
  ✓ 第1组创建成功 (6 人)
  ✓ 第2组创建成功 (2 人)

处理项目: 100米 (13 人)
  ✓ 第1组创建成功 (6 人)
  ✓ 第2组创建成功 (6 人)
  ✓ 第3组创建成功 (1 人)

生成完成: 5 个分组
```

## 影响范围

- ✅ 径赛自动分组功能正常
- ✅ 田赛分组仍需 position 验证
- ✅ 数据完整性保持

## 相关文件

- `app/models/lane.rb` - Lane 模型验证
- `app/controllers/heats_controller.rb` - 径赛分组生成
- `db/schema.rb` - lanes 表结构

## 下一步

考虑为田赛项目实现自动分组功能，需要：
1. 按年级分组
2. 设置 `position` 顺序
3. 不使用 `lane_number` 的赛道概念
