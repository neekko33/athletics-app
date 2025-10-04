# 清理旧数据
puts "\n🧹 清理旧数据..."
Athlete.destroy_all
Competition.destroy_all
Event.destroy_all
User.destroy_all

puts "\n🌱 正在导入比赛项目数据..."
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

# 插入测试用户
User.create!(email_address: "neekko33@gmail.com", password: "password")
puts "✅ 测试用户已创建，邮箱：neekko33@gmail.com，密码：password"

# 创建测试运动会
puts "\n🏃 创建测试运动会数据..."
competition = Competition.create!(
  name: "2025年秋季运动会",
  start_date: Date.new(2025, 10, 15),
  track_lanes: 8
)
puts "✅ 运动会创建成功: #{competition.name}"

# 创建3个年级（减少年级数量）
grades_data = [
  { name: "一年级", order: 1 },
  { name: "二年级", order: 2 },
  { name: "三年级", order: 3 }
]

grades = []
grades_data.each do |grade_data|
  grade = competition.grades.create!(grade_data)
  grades << grade
  puts "  ✓ 创建年级: #{grade.name}"

  # 每个年级创建2个班级（减少班级数量）
  2.times do |klass_index|
    klass = grade.klasses.create!(
      name: "#{klass_index + 1}班",
      order: klass_index + 1
    )
    puts "    ✓ 创建班级: #{grade.name} #{klass.name}"
  end
end

# 获取所有项目
all_events = Event.all
male_track_events = all_events.where(gender: "男", event_type: "track").to_a
female_track_events = all_events.where(gender: "女", event_type: "track").to_a
male_field_events = all_events.where(gender: "男", event_type: "field").to_a
female_field_events = all_events.where(gender: "女", event_type: "field").to_a

# 为每个班级创建运动员
puts "\n👥 创建运动员并分配项目..."
chinese_surnames = [ "王", "李", "张", "刘", "陈", "杨", "黄", "赵", "吴", "周" ]
chinese_names = [ "明", "强", "芳", "丽", "伟", "娟", "敏", "静", "军", "磊", "洋", "勇", "艳", "秀", "杰", "涛", "红", "超", "鹏", "辉" ]

athlete_count = 0
grades.each do |grade|
  grade.klasses.each do |klass|
    # 每个班级创建4名男生和3名女生（减少人数）

    # 男生
    4.times do |i|
      surname = chinese_surnames.sample
      given_name = chinese_names.sample(2).join
      athlete = klass.athletes.create!(
        name: "#{surname}#{given_name}",
        gender: "男"
      )

      # 随机选择1-2个径赛项目
      selected_track = male_track_events.sample(rand(1..2))
      # 随机选择0-1个田赛项目
      selected_field = rand < 0.5 ? male_field_events.sample(1) : []
      selected_events = selected_track + selected_field

      # 创建报名关联
      selected_events.each do |event|
        competition_event = competition.competition_events.find_or_create_by!(event_id: event.id)
        athlete.athlete_competition_events.create!(competition_event: competition_event)
      end

      athlete_count += 1
    end

    # 女生
    3.times do |i|
      surname = chinese_surnames.sample
      given_name = chinese_names.sample(2).join
      athlete = klass.athletes.create!(
        name: "#{surname}#{given_name}",
        gender: "女"
      )

      # 随机选择1-2个径赛项目
      selected_track = female_track_events.sample(rand(1..2))
      # 随机选择0-1个田赛项目
      selected_field = rand < 0.5 ? female_field_events.sample(1) : []
      selected_events = selected_track + selected_field

      # 创建报名关联
      selected_events.each do |event|
        competition_event = competition.competition_events.find_or_create_by!(event_id: event.id)
        athlete.athlete_competition_events.create!(competition_event: competition_event)
      end

      athlete_count += 1
    end
  end
end

puts "✅ 创建了 #{athlete_count} 名运动员，每人都有报名项目"

# 生成运动员编号
puts "\n🔢 生成运动员编号..."
athletes = competition.grades.includes(klasses: :athletes)
                      .order(:order)
                      .flat_map do |grade|
  grade.klasses.order(:order).flat_map do |klass|
    klass.athletes.order(Arel.sql("CASE WHEN gender = '男' THEN 0 WHEN gender = '女' THEN 1 END"))
  end
end

athletes.each_with_index do |athlete, index|
  athlete.update_column(:number, format("%03d", index + 1))
end

puts "✅ 编号生成完成: 001-#{format("%03d", athletes.count)}"

# 统计信息
puts "\n📊 数据统计："
puts "  运动会: #{Competition.count} 个"
puts "  年级: #{Grade.count} 个"
puts "  班级: #{Klass.count} 个"
puts "  运动员: #{Athlete.count} 人"
puts "    - 男生: #{Athlete.where(gender: '男').count} 人"
puts "    - 女生: #{Athlete.where(gender: '女').count} 人"
puts "  比赛项目: #{Event.count} 个"
puts "  报名记录: #{AthleteCompetitionEvent.count} 条"
puts "  参赛项目: #{CompetitionEvent.count} 个"

puts "\n✨ 种子数据创建完成！"
puts "=" * 60
