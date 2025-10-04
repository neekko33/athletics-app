# SQL 保留关键字问题修复

## 问题描述

在查询分组时出现 SQL 语法错误：
```
SQLite3::SQLException: near "order": syntax error
```

## 原因分析

`order` 是 SQLite（和大多数 SQL 数据库）的保留关键字，用于 `ORDER BY` 子句。

在我们的数据库中，`grades` 表有一个名为 `order` 的列，用于存储年级的排序顺序：

```ruby
# db/schema.rb
create_table "grades" do |t|
  t.string "name"
  t.integer "order"  # ← 这是保留关键字
  # ...
end
```

当在 SQL 查询中直接使用 `grades.order` 时，数据库会将其误解为 SQL 关键字而不是列名。

## 解决方案

在 SQL 查询中使用双引号包裹列名：

### 修改前
```ruby
competition_event.heats.includes(:grade).order('grades.order', :heat_number)
```

### 修改后
```ruby
competition_event.heats.includes(:grade).order('grades."order"', :heat_number)
```

## 修改的文件

### app/views/heats/index.html.erb

两处修改：

**径赛分组排序**（第 25 行）：
```erb
<% competition_event.heats.includes(:grade).order('grades."order"', :heat_number).each do |heat| %>
```

**田赛分组排序**（第 109 行）：
```erb
<% competition_event.heats.includes(:grade).order('grades."order"').each do |heat| %>
```

## 测试验证

```ruby
# 测试查询
heats = competition_event.heats.includes(:grade).order('grades."order"', :heat_number)
# ✓ 成功，没有 SQL 错误
```

## 其他保留关键字

在 SQLite 中常见的保留关键字包括：
- `order`
- `group`
- `index`
- `table`
- `select`
- `where`
- `from`
- 等等...

如果以后使用这些名称作为列名，同样需要用引号包裹。

## 最佳实践

### 避免使用保留关键字
尽量避免使用 SQL 保留关键字作为列名：
- ❌ `order` → ✅ `sort_order` 或 `position`
- ❌ `group` → ✅ `group_name` 或 `grouping`
- ❌ `index` → ✅ `order_index` 或 `sequence`

### 如果必须使用
当必须使用保留关键字时，确保：
1. 在 SQL 查询中用引号包裹
2. 在迁移中使用符号而不是字符串
3. 文档中说明该字段的特殊性

## 相关链接

- SQLite 保留关键字列表：https://www.sqlite.org/lang_keywords.html
- Rails Active Record 查询指南：https://guides.rubyonrails.org/active_record_querying.html

## 注意事项

1. **双引号 vs 单引号**：在 SQL 中，双引号用于标识符（表名、列名），单引号用于字符串值
2. **数据库差异**：不同数据库的保留关键字可能不同
3. **迁移安全**：现有数据库已有 `order` 列，无需修改结构，只需在查询时处理即可
