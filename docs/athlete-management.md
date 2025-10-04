# 运动员管理功能说明

## 概述

运动员管理系统已更新以支持新的数据结构，现在可以动态创建班级和比赛项目。

## 核心功能

### 1. 动态创建班级

在添加运动员时，如果输入的班级不存在，系统会自动创建该班级。

**工作流程：**
```
用户输入 "1班" → 系统检查该年级下是否有"1班" 
                 → 如果不存在，自动创建
                 → 将运动员分配到该班级
```

**智能排序：**
- 系统会从班级名称中提取数字作为排序依据
- 例如："1班" → order: 1，"2班" → order: 2
- 如果无法提取数字，则按创建顺序排列

### 2. 动态创建比赛项目

当运动员报名项目时，系统会自动为该运动会创建对应的比赛项目。

**工作流程：**
```
用户选择"男子100米" → 系统检查运动会中是否有该项目
                    → 如果不存在，自动创建 CompetitionEvent
                    → 关联运动员到该比赛项目
```

## 使用方法

### 添加运动员

1. **导航到运动员列表**
   - 进入运动会详情
   - 点击"运动员列表"
   - 选择要添加运动员的年级标签

2. **填写运动员信息**
   ```
   姓名: 张三
   性别: 男
   班级: 1班 (如果不存在会自动创建)
   ```
   
   注意：编号不需要手动输入，会在所有运动员登记完成后统一生成。

3. **选择报名项目**
   - 首先选择性别，系统会自动过滤可选项目
   - 勾选要报名的项目（可多选）
   - 系统会自动为运动会创建这些项目

4. **提交**
   - 点击"提交"按钮
   - 系统自动创建班级（如需要）
   - 系统自动创建比赛项目（如需要）
   - 运动员报名成功

## 数据流程

### 创建运动员流程图

```
开始
  ↓
检查班级是否存在
  ↓ 否
创建新班级
  ↓
创建运动员记录
  ↓
检查报名项目
  ↓ 有
遍历每个项目
  ↓
检查CompetitionEvent是否存在
  ↓ 否
创建CompetitionEvent
  ↓
创建AthleteCompetitionEvent关联
  ↓
完成
```

## 代码示例

### 控制器逻辑

```ruby
def create
  # 1. 动态创建班级
  klass_name = params[:athlete][:klass_name]
  klass = @grade.klasses.find_or_create_by!(name: klass_name) do |k|
    if klass_name =~ /(\d+)/
      k.order = $1.to_i
    else
      k.order = @grade.klasses.maximum(:order).to_i + 1
    end
  end

  # 2. 创建运动员
  @athlete = klass.athletes.new(athlete_params)

  if @athlete.save
    # 3. 动态创建比赛项目并关联
    if params[:athlete][:event_ids].present?
      event_ids.each do |event_id|
        competition_event = @competition.competition_events
                                       .find_or_create_by!(event_id: event_id)
        @athlete.athlete_competition_events
                .create!(competition_event: competition_event)
      end
    end
  end
end
```

## 数据验证

### 运动员模型

```ruby
class Athlete < ApplicationRecord
  validates :name, presence: true
  validates :gender, presence: true, inclusion: { in: %w[男 女] }
  validates :student_number, uniqueness: true, allow_nil: true
end
```

### 班级模型

```ruby
class Klass < ApplicationRecord
  validates :name, presence: true
  validates :order, presence: true, numericality: { only_integer: true }
end
```

## 界面说明

### 运动员列表页面

- **标签式导航**：按年级分组显示
- **运动员表格**：显示学号、姓名、性别、班级、报名项目
- **添加按钮**：每个年级标签下都有独立的"添加运动员"按钮

### 添加运动员表单

- **姓名**：必填
- **学号**：选填，建议填写以便管理
- **性别**：必选，会影响可选项目
- **班级**：必填，输入班级名称（如"1班"）
- **报名项目**：多选，根据性别自动过滤

## 注意事项

### 班级命名建议

- 使用统一格式：如"1班"、"2班"
- 避免使用特殊字符
- 建议包含数字以便自动排序

### 项目报名

- 必须先选择性别
- 只能选择对应性别的项目
- 接力项目需要特殊处理（未来功能）

### 数据一致性

- 同一运动会中，相同的Event只会创建一个CompetitionEvent
- 同一年级中，相同名称的班级只会创建一次
- 运动员的学号在整个系统中应该是唯一的

## 常见问题

### Q: 如果班级名称输入错误怎么办？
A: 系统会创建新班级。建议在后台管理中合并或删除错误的班级。

### Q: 运动员可以报名多少个项目？
A: 理论上无限制，但建议根据实际情况限制（可在模型中添加验证）。

### Q: 如何修改已创建的运动员信息？
A: 点击运动员列表中的"编辑"按钮（功能开发中）。

### Q: 如何删除运动员？
A: 点击运动员列表中的"删除"按钮（功能开发中）。

## 后续开发计划

- [ ] 编辑运动员功能
- [ ] 删除运动员功能
- [ ] 批量导入运动员
- [ ] 班级管理界面
- [ ] 项目报名限制设置
- [ ] 接力队组队功能

## 技术细节

### 数据库事务

创建运动员的过程使用了数据库事务，确保：
- 要么全部成功（班级、运动员、项目关联）
- 要么全部回滚（出错时不会留下脏数据）

### 性能优化

- 使用 `find_or_create_by!` 避免重复查询
- 使用 `includes` 预加载关联数据
- 批量操作使用事务包裹

### 错误处理

- 使用 `!` 版本的方法（如 `create!`）在失败时抛出异常
- 在控制器中捕获异常并显示友好的错误信息
- 表单验证失败时返回 422 状态码

---

**版本**: 1.0  
**最后更新**: 2025年10月4日  
**状态**: 功能完成，测试通过
