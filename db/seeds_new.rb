# 数据迁移和种子数据脚本

puts "🏃 开始数据迁移和初始化..."

# 1. 创建测试用户
unless User.exists?(email_address: "neekko33@gmail.com")
  User.create!(email_address: "neekko33@gmail.com", password: "password")
  puts "✅ 测试用户已创建"
end

# 2. 创建运动会
competition = Competition.find_or_create_by!(name: "2025年秋季运动会") do |c|
  c.start_date = Date.today + 30.days
end
puts "✅ 运动会已创建: #{competition.name}"

# 3. 创建年级
grades_data = [
  { name: "一年级", order: 1 },
  { name: "二年级", order: 2 },
  { name: "三年级", order: 3 },
  { name: "四年级", order: 4 },
  { name: "五年级", order: 5 },
  { name: "六年级", order: 6 }
]

grades = grades_data.map do |grade_data|
  competition.grades.find_or_create_by!(name: grade_data[:name]) do |g|
    g.order = grade_data[:order]
  end
end
puts "✅ 创建了 #{grades.count} 个年级"

# 4. 为每个年级创建班级
klasses = []
grades.each do |grade|
  (1..4).each do |class_num|
    klass = grade.klasses.find_or_create_by!(name: "#{class_num}班") do |c|
      c.order = class_num
    end
    klasses << klass
  end
end
puts "✅ 创建了 #{klasses.count} 个班级"

# 5. 创建示例运动员（每个班级5名运动员）
athlete_count = 0
klasses.each do |klass|
  (1..5).each do |i|
    gender = i.odd? ? "男" : "女"
    klass.athletes.find_or_create_by!(
      name: "#{klass.full_name}学生#{i}",
      gender: gender,
      student_number: "#{klass.grade.order}#{klass.order}#{i.to_s.rjust(2, '0')}"
    )
    athlete_count += 1
  end
end
puts "✅ 创建了 #{athlete_count} 名运动员"

# 6. 创建工作人员
staff_roles = [
  { name: "张裁判", role: "judge", contact: "13800138001" },
  { name: "李计时", role: "timer", contact: "13800138002" },
  { name: "王记录", role: "recorder", contact: "13800138003" },
  { name: "赵协调", role: "coordinator", contact: "13800138004" },
  { name: "孙医务", role: "medical", contact: "13800138005" }
]

staff_roles.each do |staff_data|
  competition.staff.find_or_create_by!(name: staff_data[:name]) do |s|
    s.role = staff_data[:role]
    s.contact = staff_data[:contact]
  end
end
puts "✅ 创建了 #{competition.staff.count} 名工作人员"

# 7. 确保事件已创建（从原 seeds.rb）
unless Event.any?
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

  field_events = [
    { name: "跳高", gender: "男", event_type: "field", avg_time: 20, max_participants: 99 },
    { name: "跳高", gender: "女", event_type: "field", avg_time: 20, max_participants: 99 },
    { name: "跳远", gender: "男", event_type: "field", avg_time: 15, max_participants: 99 },
    { name: "跳远", gender: "女", event_type: "field", avg_time: 15, max_participants: 99 },
    { name: "实心球", gender: "男", event_type: "field", avg_time: 15, max_participants: 99 },
    { name: "实心球", gender: "女", event_type: "field", avg_time: 15, max_participants: 99 }
  ]

  Event.create!(track_events + field_events)
  puts "✅ 创建了 #{Event.count} 个比赛项目"
end

# 8. 为运动会添加一些比赛项目并创建日程
Event.limit(5).each_with_index do |event, index|
  comp_event = competition.competition_events.find_or_create_by!(event: event)

  # 创建日程
  unless comp_event.schedule
    comp_event.create_schedule!(
      scheduled_at: competition.start_date.to_time + 9.hours + (index * 30).minutes,
      venue: index.even? ? "田径场A" : "田径场B",
      duration: event.avg_time,
      status: "pending",
      display_order: index + 1
    )
  end
end
puts "✅ 为运动会添加了示例比赛项目和日程"

puts "\n🎉 数据初始化完成！"
puts "\n📊 数据统计:"
puts "  运动会: #{Competition.count}"
puts "  年级: #{Grade.count}"
puts "  班级: #{Klass.count}"
puts "  运动员: #{Athlete.count}"
puts "  工作人员: #{Staff.count}"
puts "  比赛项目: #{Event.count}"
puts "  运动会项目: #{CompetitionEvent.count}"
puts "  日程安排: #{Schedule.count}"
puts "\n🔐 登录信息:"
puts "  邮箱: neekko33@gmail.com"
puts "  密码: password"
