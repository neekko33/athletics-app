# 分组逻辑重构说明 V2

## 核心变更

重新设计了径赛和田赛的自动分组逻辑，确保**同一分组内的运动员必须来自同一年级**。

## 新的分组规则

### 1. 径赛项目（Track Events）

**分组原则**：年级优先 → 人数分组

**流程**：
1. 首先按年级分组
2. 每个年级的运动员单独处理
3. 如果该年级人数 > 赛道数，则该年级内再次分组
4. 每组最多 `track_lanes` 人（赛道数量）
5. 赛道从1号开始连续分配

**示例**：
```
项目: 100米（6条赛道）
├── 一年级: 6人 → 1组（赛道1-6）
├── 二年级: 3人 → 1组（赛道1-3）
├── 三年级: 8人 → 2组
│   ├── 第1组: 6人（赛道1-6）
│   └── 第2组: 2人（赛道1-2）
└── 四年级: 1人 → 1组（赛道1）
```

### 2. 田赛项目（Field Events）

**分组原则**：仅按年级分组，不限人数

**流程**：
1. 按年级分组
2. 每个年级一个分组
3. 年级内所有运动员随机排序
4. 使用 `position` 字段标识试跳/试投顺序

**示例**：
```
项目: 跳远
├── 一年级: 12人 → 1组（位置1-12）
├── 二年级: 8人 → 1组（位置1-8）
└── 三年级: 5人 → 1组（位置1-5）
```

### 3. 接力项目（Relay Events）

**分组原则**：年级 → 班级，每个赛道4人同班级

**流程**：
1. 先按年级分组
2. 年级内按班级分组
3. 每个班级必须有至少4人才能参加
4. 人数不足4人的班级会生成警告消息
5. 有效队伍按班级分配到赛道

**人数检查**：
- ✓ 4人或以上：可以参赛
- ✗ 少于4人：显示警告"XX年级 XX班 只有X人（需要4人）"

**示例**：
```
项目: 4x100米接力
├── 一年级
│   ├── 1班: 5人 → 第1组 赛道1（随机选4人）
│   ├── 2班: 3人 → ⚠️ 警告：人数不足
│   └── 3班: 6人 → 第1组 赛道2（随机选4人）
└── 二年级
    ├── 1班: 4人 → 第1组 赛道1（全部4人）
    └── 2班: 8人 → 第1组 赛道2（随机选4人）
```

## 代码实现

### 控制器方法

#### 1. generate_all（径赛）
```ruby
def generate_all
  track_events.each do |competition_event|
    athletes = competition_event.athletes
    
    if is_relay
      # 接力：年级 → 班级分组
      athletes.group_by { |a| a.klass.grade }.each do |grade, grade_athletes|
        athletes_by_klass = grade_athletes.group_by(&:klass)
        # 检查每个班级人数 >= 4
      end
    else
      # 普通径赛：年级分组 → 人数分组
      athletes.group_by { |a| a.klass.grade }.each do |grade, grade_athletes|
        heat_count = (grade_athletes.count / track_lanes).ceil
        # 创建多个分组
      end
    end
  end
end
```

#### 2. generate_field_events（田赛）
```ruby
def generate_field_events
  field_events.each do |competition_event|
    athletes = competition_event.athletes
    
    # 田赛：仅年级分组
    athletes.group_by { |a| a.klass.grade }.each do |grade, grade_athletes|
      heat = competition_event.heats.create!(
        grade: grade,
        heat_number: 1,
        total_lanes: grade_athletes.count
      )
      
      # 设置 position（试跳/试投顺序）
      grade_athletes.shuffle.each_with_index do |athlete, index|
        lane = heat.lanes.create!(
          lane_number: index + 1,
          position: index + 1
        )
      end
    end
  end
end
```

### 数据模型

#### Heat 模型
```ruby
belongs_to :grade, optional: true  # 现在必须有 grade（除非为空数据）
validates :grade_id, presence: true, if: :field_event?  # 田赛必须有年级
```

#### Lane 模型
```ruby
validates :position, presence: true, if: :field_event?  # 田赛需要 position
validates :lane_number, presence: true  # 所有项目都需要 lane_number
```

## 视图更新

### heats/index.html.erb

**变更**：
1. 分为两个部分：径赛分组 + 田赛分组
2. 两个独立的"自动生成"按钮
3. 分组标题显示年级信息：`一年级 - 第1组`

**径赛显示**：
- 网格布局（6列，根据赛道数）
- 显示赛道号 + 运动员信息
- 蓝色背景表示有人，灰色表示空赛道

**田赛显示**：
- 网格布局（8列）
- 显示位置号 + 运动员信息
- 绿色背景区分田赛
- 无空位概念（人数即位置数）

## 警告和错误处理

### 接力项目警告
```ruby
warnings = []

if klass_athletes.count < 4
  warnings << "#{grade.name} #{klass.name} 只有#{klass_athletes.count}人（需要4人）"
end

if warnings.any?
  flash[:warning] = "生成完成，但有以下警告：<br/>#{warnings.join('<br/>')}"
end
```

### 显示效果
```
⚠️ 生成完成，但有以下警告：
4x100米接力 - 一年级 2班 只有3人（需要4人）
4x100米接力 - 二年级 3班 只有2人（需要4人）
```

## 路由配置

```ruby
resources :heats do
  collection do
    post :generate_all           # 径赛自动分组
    post :generate_field_events  # 田赛自动分组
  end
end
```

## 测试验证

### 径赛测试
```ruby
# 测试：100米（6条赛道）
一年级: 6人 → 1组（赛道1-6）
二年级: 3人 → 1组（赛道1-3）
三年级: 8人 → 2组
  第1组: 6人（赛道1-6）
  第2组: 2人（赛道1-2）
```

### 田赛测试
```ruby
# 测试：跳远
一年级: 12人 → 1组（位置1-12）
二年级: 8人 → 1组（位置1-8）
```

### 接力测试
```ruby
# 测试：4x100米接力
一年级
  1班: 5人 → 有效队伍
  2班: 3人 → ⚠️ 警告
二年级
  1班: 4人 → 有效队伍
```

## 优势

1. **符合比赛规则**：不同年级分开比赛
2. **公平性**：同年级运动员在相同条件下竞争
3. **清晰易懂**：分组逻辑简单明了
4. **灵活处理**：自动适应不同年级人数
5. **错误提示**：接力项目人数不足时给出明确警告

## 注意事项

1. **年级必填**：所有运动员必须有年级信息
2. **接力人数**：班级人数不足4人无法参加接力
3. **田赛不限人数**：田赛按年级分组，不限每组人数
4. **径赛超员分组**：年级内人数超过赛道数时自动多组

## 未来优化

1. 支持手动调整分组
2. 导出分组名单
3. 分组统计报表
4. 批量打印分组信息
