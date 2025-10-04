# 径赛项目 6个赛道
track_events = [
  { name: "100米", gender: "男", event_type: "track", avg_time: 5, max_participants: 6 },
  { name: "100米", gender: "女", event_type: "track", avg_time: 5, max_participants: 6 },
  { name: "200米", gender: "男", event_type: "track", avg_time: 6, max_participants: 6 },
  { name: "200米", gender: "女", event_type: "track", avg_time: 6, max_participants: 6 },
  { name: "400米", gender: "男", event_type: "track", avg_time: 8, max_participants: 6 },
  { name: "400米", gender: "女", event_type: "track", avg_time: 8, max_participants: 6 },
  { name: "800米", gender: "女", event_type: "track", avg_time: 10, max_participants: 6 },
  { name: "1000米", gender: "男", event_type: "track", avg_time: 12, max_participants: 6 },
  { name: "4×100米接力", gender: "男", event_type: "track", avg_time: 8, max_participants: 24 },
  { name: "4×100米接力", gender: "女", event_type: "track", avg_time: 8, max_participants: 24 }
]

# 田赛项目 不限人数
field_events = [
  { name: "跳高", gender: "男", event_type: "field", avg_time: 20, max_participants: 99 },
  { name: "跳高", gender: "女", event_type: "field", avg_time: 20, max_participants: 99 },
  { name: "跳远", gender: "男", event_type: "field", avg_time: 15, max_participants: 99 },
  { name: "跳远", gender: "女", event_type: "field", avg_time: 15, max_participants: 99 },
  { name: "实心球", gender: "男", event_type: "field", avg_time: 15, max_participants: 99 },
  { name: "实心球", gender: "女", event_type: "field", avg_time: 15, max_participants: 99 }
]

# 插入数据
Event.create!(track_events + field_events)
puts "✅ #{Event.count} 个比赛项目已成功导入。"

# 插入测试用户，方便登录（生产环境请删除）
User.create!(email_address: "neekko33@gmail.com", password: "password")
puts "✅ 测试用户已创建，邮箱：neekko33@gmail.com，密码：password"
