# 清空旧数据
Event.delete_all

# 径赛项目
track_events = [
  { name: "男子100米", event_type: "track", avg_time: 5, max_participants: 8 },
  { name: "女子100米", event_type: "track", avg_time: 5, max_participants: 8 },
  { name: "男子200米", event_type: "track", avg_time: 6, max_participants: 8 },
  { name: "女子200米", event_type: "track", avg_time: 6, max_participants: 8 },
  { name: "男子400米", event_type: "track", avg_time: 8, max_participants: 8 },
  { name: "女子400米", event_type: "track", avg_time: 8, max_participants: 8 },
  { name: "男子800米", event_type: "track", avg_time: 10, max_participants: 12 },
  { name: "女子800米", event_type: "track", avg_time: 10, max_participants: 12 },
  { name: "男子1000米", event_type: "track", avg_time: 12, max_participants: 12 },
  { name: "女子1000米", event_type: "track", avg_time: 12, max_participants: 12 },
  { name: "男子4×100米接力", event_type: "track", avg_time: 8, max_participants: 32 },
  { name: "女子4×100米接力", event_type: "track", avg_time: 8, max_participants: 32 }
]

# 田赛项目
field_events = [
  { name: "男子跳高", event_type: "field", avg_time: 20, max_participants: 10 },
  { name: "女子跳高", event_type: "field", avg_time: 20, max_participants: 10 },
  { name: "男子跳远", event_type: "field", avg_time: 15, max_participants: 12 },
  { name: "女子跳远", event_type: "field", avg_time: 15, max_participants: 12 },
  { name: "男子实心球", event_type: "field", avg_time: 15, max_participants: 12 },
  { name: "女子实心球", event_type: "field", avg_time: 15, max_participants: 12 }
]

# 插入数据
Event.create!(track_events + field_events)

puts "✅ #{Event.count} 个比赛项目已成功导入。"
