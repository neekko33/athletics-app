# 清理旧数据
puts "\n🧹 清理旧数据..."
Athlete.destroy_all
Competition.destroy_all
Event.destroy_all
User.destroy_all

# 重置主键序列（SQLite）
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='competitions'")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='events'")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='users'")
ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='athletes'")

puts "\n🌱 正在导入比赛项目数据..."
# 径赛项目
track_events = [
  { name: "100米", gender: "男", event_type: "track", avg_time: 5, max_participants: 6 },
  { name: "100米", gender: "女", event_type: "track", avg_time: 5, max_participants: 6 },
  { name: "200米", gender: "男", event_type: "track", avg_time: 6, max_participants: 6 },
  { name: "200米", gender: "女", event_type: "track", avg_time: 6, max_participants: 6 },
  { name: "400米", gender: "男", event_type: "track", avg_time: 8, max_participants: 6 },
  { name: "400米", gender: "女", event_type: "track", avg_time: 8, max_participants: 6 },
  { name: "800米", gender: "男", event_type: "track", avg_time: 10, max_participants: 6 },
  { name: "800米", gender: "女", event_type: "track", avg_time: 10, max_participants: 6 },
  { name: "1500米", gender: "男", event_type: "track", avg_time: 12, max_participants: 6 },
  { name: "1500米", gender: "女", event_type: "track", avg_time: 12, max_participants: 6 },
  { name: "4×100米接力", gender: "男", event_type: "track", avg_time: 8, max_participants: 24 },
  { name: "4×100米接力", gender: "女", event_type: "track", avg_time: 8, max_participants: 24 }
]

# 田赛项目
field_events = [
  { name: "跳高", gender: "男", event_type: "field", avg_time: 20, max_participants: 99 },
  { name: "跳高", gender: "女", event_type: "field", avg_time: 20, max_participants: 99 },
  { name: "跳远", gender: "男", event_type: "field", avg_time: 15, max_participants: 99 },
  { name: "跳远", gender: "女", event_type: "field", avg_time: 15, max_participants: 99 }
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
  end_date: Date.new(2025, 10, 17),
  track_lanes: 6
)
puts "✅ 运动会创建成功: #{competition.name}"

# 创建年级和班级
puts "\n📚 创建年级和班级..."
grades_data = [
  { name: "七年级", order: 1, class_count: 5 },
  { name: "八年级", order: 2, class_count: 6 }
]

def number_to_chinese(number)
    chinese_numbers = {
      "0" => "零", "1" => "一", "2" => "二", "3" => "三", "4" => "四",
      "5" => "五", "6" => "六", "7" => "七", "8" => "八", "9" => "九",
      "10" => "十", "11" => "十一", "12" => "十二"
    }

    chinese_numbers[number.to_s] || number.to_s
end

grades = {}
grades_data.each do |grade_data|
  grade = competition.grades.create!(
    name: grade_data[:name],
    order: grade_data[:order]
  )
  grades[grade_data[:name]] = grade
  puts "  ✓ 创建年级: #{grade.name}"

  grade_data[:class_count].times do |klass_index|
    klass = grade.klasses.create!(
      name: "#{number_to_chinese(klass_index + 1)}班",
      order: klass_index + 1
    )
    puts "    ✓ 创建班级: #{grade.name} #{klass.name}"
  end
end

# 获取所有项目（创建 CompetitionEvent）
all_events = Event.all
competition_events = {}
all_events.each do |event|
  ce = competition.competition_events.find_or_create_by!(event_id: event.id)
  competition_events["#{event.name}_#{event.gender}"] = ce
end

puts "\n👥 导入真实运动员数据..."

# 七年级男子组数据
grade_7_male_athletes = [
  # 100米参赛运动员（10人）
  { number: "001", name: "王勋然", klass: "一班", events: ["100米", "400米"] },
  { number: "013", name: "刘天昊", klass: "二班", events: ["100米", "800米"] },
  { number: "030", name: "刘世雨", klass: "三班", events: ["100米", "200米"] },
  { number: "037", name: "高志国", klass: "四班", events: ["100米", "800米"] },
  { number: "049", name: "李帅威", klass: "五班", events: ["100米", "200米"] },
  { number: "028", name: "李子默", klass: "三班", events: ["100米", "跳高"] },
  { number: "018", name: "翟聪颖", klass: "二班", events: ["100米"] },
  { number: "002", name: "闫肃", klass: "一班", events: ["100米", "跳远"] },
  { number: "038", name: "杨毅哲", klass: "四班", events: ["100米", "1500米"] },
  { number: "050", name: "梁世博", klass: "五班", events: ["100米", "200米"] },
  
  # 200米参赛运动员（额外的）
  { number: "039", name: "郝子淳", klass: "四班", events: ["200米", "跳远"] },
  { number: "029", name: "王勋涛", klass: "一班", events: ["200米", "800米"] },
  { number: "014", name: "李晓淼", klass: "二班", events: ["200米", "400米"] },
  { number: "040", name: "姚家乐", klass: "四班", events: ["200米", "跳远"] },
  { number: "006", name: "赵宗鑫", klass: "一班", events: ["200米", "1500米"] },
  { number: "026", name: "王若天", klass: "三班", events: ["200米", "1500米"] },
  { number: "017", name: "杨子杰", klass: "二班", events: ["200米"] },
  
  # 400米参赛运动员（额外的）
  { number: "041", name: "李天佑", klass: "四班", events: ["400米", "跳高"] },
  { number: "027", name: "张子赫", klass: "三班", events: ["400米", "800米"] },
  { number: "054", name: "张舒恺", klass: "五班", events: ["400米", "跳远"] },
  { number: "042", name: "靳文士", klass: "四班", events: ["400米"] },
  { number: "053", name: "赵富恒", klass: "五班", events: ["400米", "跳远"] },
  { number: "015", name: "胡雪涛", klass: "二班", events: ["400米", "1500米"] },
  { number: "004", name: "尹国轩", klass: "一班", events: ["400米", "1500米"] },
  
  # 800米参赛运动员（额外的）
  { number: "003", name: "张道聪", klass: "一班", events: ["800米", "跳远"] },
  { number: "005", name: "王勋涛", klass: "一班", events: ["800米"] }, # 重名处理
  { number: "016", name: "马子孑", klass: "二班", events: ["800米", "1500米"] },
  { number: "051", name: "秦开明", klass: "五班", events: ["800米", "1500米"] },
  { number: "052", name: "张自言", klass: "五班", events: ["800米", "1500米"] },
  
  # 1500米参赛运动员（额外的）
  { number: "029", name: "丁灿", klass: "三班", events: ["1500米", "跳远"] },
  
  # 跳高参赛运动员（额外的）
  { number: "025", name: "高有诺", klass: "三班", events: ["跳高", "跳远"] },
]

# 七年级女子组数据
grade_7_female_athletes = [
  # 100米参赛运动员
  { number: "007", name: "董雨若", klass: "一班", events: ["100米"] },
  { number: "019", name: "赵飞雪", klass: "二班", events: ["100米", "200米"] },
  { number: "034", name: "王晓雅", klass: "三班", events: ["100米", "跳高"] },
  { number: "043", name: "王子玥", klass: "四班", events: ["100米"] },
  { number: "056", name: "曹可欣", klass: "五班", events: ["100米"] },
  { number: "044", name: "王宇喧", klass: "四班", events: ["100米"] },
  { number: "057", name: "张淑妍", klass: "五班", events: ["100米", "跳高"] },
  { number: "010", name: "管刘烨", klass: "一班", events: ["100米", "800米"] },
  { number: "022", name: "吴婉如", klass: "二班", events: ["100米", "400米"] },
  { number: "033", name: "王念念", klass: "三班", events: ["100米", "跳高"] },
  
  # 200米参赛运动员（额外的）
  { number: "032", name: "曹晓婉", klass: "三班", events: ["200米", "跳远"] },
  { number: "045", name: "刘子涵", klass: "四班", events: ["200米"] },
  { number: "055", name: "段萌萌", klass: "五班", events: ["200米", "400米"] },
  { number: "012", name: "冯闰涵", klass: "一班", events: ["200米", "跳高"] },
  { number: "021", name: "苏雪", klass: "二班", events: ["200米", "800米"] },
  { number: "036", name: "刘洋", klass: "三班", events: ["200米", "800米"] },
  { number: "058", name: "高含香", klass: "五班", events: ["200米", "400米"] },
  { number: "044", name: "张优", klass: "四班", events: ["200米"] },
  
  # 400米参赛运动员（额外的）
  { number: "031", name: "鲍佳琦", klass: "三班", events: ["400米", "800米"] },
  { number: "008", name: "车俊雅", klass: "一班", events: ["400米", "800米"] },
  { number: "047", name: "任沁怡", klass: "四班", events: ["400米", "800米"] },
  { number: "009", name: "张惜诺", klass: "一班", events: ["400米", "跳远"] },
  { number: "048", name: "袁子姿", klass: "四班", events: ["400米", "800米"] },
  { number: "024", name: "房念思", klass: "二班", events: ["400米", "跳高"] },
  { number: "035", name: "张若熙", klass: "三班", events: ["400米", "跳远"] },
  
  # 800米参赛运动员（额外的）
  { number: "023", name: "方依冉", klass: "二班", events: ["800米", "1500米"] },
  { number: "057", name: "张淑鑫", klass: "五班", events: ["800米"] },
  { number: "059", name: "谷余乐", klass: "五班", events: ["800米", "跳高"] },
  
  # 1500米参赛运动员
  { number: "020", name: "王语晴", klass: "二班", events: ["1500米", "跳远"] },
  
  # 跳高参赛运动员（额外的）
  { number: "011", name: "李冰冰", klass: "一班", events: ["跳高", "跳远"] },
  { number: "060", name: "张淑妍", klass: "五班", events: ["跳高"] },
]

# 八年级男子组数据
grade_8_male_athletes = [
  # 100米参赛运动员
  { number: "101", name: "张晨光", klass: "一班", events: ["100米", "跳高"] },
  { number: "116", name: "张佳博", klass: "二班", events: ["100米", "400米"] },
  { number: "126", name: "巴瑞康", klass: "三班", events: ["100米", "400米"] },
  { number: "138", name: "刘焱康", klass: "四班", events: ["100米", "200米"] },
  { number: "149", name: "薛王博", klass: "五班", events: ["100米", "1500米"] },
  { number: "166", name: "黄海诺", klass: "六班", events: ["100米", "200米"] },
  { number: "165", name: "刘天齐", klass: "六班", events: ["100米", "200米"] },
  { number: "102", name: "谷正荣", klass: "一班", events: ["100米", "跳高", "跳远"] },
  { number: "139", name: "刘硕", klass: "四班", events: ["100米", "800米"] },
  { number: "129", name: "李首彦", klass: "三班", events: ["100米", "跳远"] },
  { number: "153", name: "于佳辉", klass: "五班", events: ["100米", "200米"] },
  
  # 200米参赛运动员（额外的）
  { number: "137", name: "后文强", klass: "四班", events: ["200米", "跳远"] },
  { number: "125", name: "郑叶硕", klass: "三班", events: ["200米", "跳高"] },
  { number: "115", name: "武冰璨", klass: "二班", events: ["200米", "跳远"] },
  { number: "105", name: "董成挡", klass: "一班", events: ["200米", "800米"] },
  { number: "106", name: "张晗旭", klass: "一班", events: ["200米", "跳远"] },
  { number: "113", name: "任远通", klass: "二班", events: ["200米", "800米"] },
  { number: "130", name: "张国宇", klass: "三班", events: ["200米", "400米"] },
  
  # 400米参赛运动员（额外的）
  { number: "103", name: "郭子翔", klass: "一班", events: ["400米", "800米"] },
  { number: "164", name: "邢丙衡", klass: "六班", events: ["400米", "跳远"] },
  { number: "150", name: "李浩然", klass: "五班", events: ["400米", "800米"] },
  { number: "141", name: "张百超", klass: "四班", events: ["400米", "800米"] },
  { number: "152", name: "李浩鑫", klass: "五班", events: ["400米", "800米"] },
  { number: "117", name: "田宪哲", klass: "二班", events: ["400米", "跳远"] },
  { number: "104", name: "马国苗", klass: "一班", events: ["400米", "跳远"] },
  { number: "161", name: "尹泽浩", klass: "六班", events: ["400米"] },
  
  # 800米参赛运动员（额外的）
  { number: "114", name: "马晓赫", klass: "二班", events: ["800米", "跳高"] },
  { number: "127", name: "张扬", klass: "三班", events: ["800米", "跳高"] },
  { number: "162", name: "王位东", klass: "六班", events: ["800米", "跳高"] },
  
  # 1500米参赛运动员（额外的）
  { number: "118", name: "张帆", klass: "二班", events: ["1500米", "跳高"] },
  { number: "128", name: "孟泽熙", klass: "三班", events: ["1500米", "跳远"] },
  { number: "142", name: "刘德治", klass: "四班", events: ["1500米", "跳高"] },
  { number: "154", name: "崔镇烁", klass: "五班", events: ["1500米", "跳高"] },
  { number: "161", name: "尹哲浩", klass: "六班", events: ["1500米"] },
  
  # 跳高参赛运动员（额外的）
  { number: "151", name: "李朝旭", klass: "五班", events: ["跳高", "跳远"] },
  { number: "163", name: "杨永健", klass: "六班", events: ["跳高", "跳远"] },
  { number: "140", name: "刘记越", klass: "四班", events: ["跳高", "跳远"] },
]

# 八年级女子组数据
grade_8_female_athletes = [
  # 100米参赛运动员
  { number: "110", name: "谷言", klass: "一班", events: ["100米", "跳远"] },
  { number: "119", name: "葛晓艺", klass: "二班", events: ["100米", "1500米"] },
  { number: "131", name: "方梦瑶", klass: "三班", events: ["100米", "800米"] },
  { number: "147", name: "李珊珊", klass: "四班", events: ["100米", "200米"] },
  { number: "159", name: "肖雪妍", klass: "五班", events: ["100米", "200米"] },
  { number: "167", name: "王依诺", klass: "六班", events: ["100米", "200米"] },
  { number: "112", name: "任焓雪", klass: "一班", events: ["100米", "800米"] },
  { number: "122", name: "田晓涵", klass: "二班", events: ["100米", "200米"] },
  { number: "135", name: "李梦鑫", klass: "三班", events: ["100米", "跳远"] },
  { number: "148", name: "刘晨雪", klass: "四班", events: ["100米", "跳远"] },
  { number: "160", name: "郝琪琪", klass: "五班", events: ["100米", "跳高"] },
  { number: "168", name: "贾梦佳", klass: "六班", events: ["100米", "400米"] },
  
  # 200米参赛运动员（额外的）
  { number: "107", name: "闫研", klass: "一班", events: ["200米", "400米"] },
  { number: "120", name: "刘抒情", klass: "二班", events: ["200米", "跳远"] },
  { number: "133", name: "胡傲婷", klass: "三班", events: ["200米", "跳高"] },
  { number: "156", name: "梁佳依", klass: "五班", events: ["200米", "800米"] },
  { number: "170", name: "夏怡欣", klass: "六班", events: ["200米", "400米"] },
  { number: "108", name: "李雨昕", klass: "一班", events: ["200米", "跳远"] },
  { number: "136", name: "杜佳琪", klass: "三班", events: ["200米", "400米"] },
  { number: "146", name: "李紫诺", klass: "四班", events: ["200米", "400米"] },
  
  # 400米参赛运动员（额外的）
  { number: "157", name: "孙晨妍", klass: "五班", events: ["400米", "跳远"] },
  { number: "109", name: "刘毅云", klass: "一班", events: ["400米", "800米"] },
  { number: "123", name: "王语馨", klass: "二班", events: ["400米", "跳高"] },
  { number: "134", name: "王梦晗", klass: "三班", events: ["400米", "跳远"] },
  { number: "124", name: "孙雪妍", klass: "二班", events: ["400米", "800米"] },
  { number: "158", name: "周灿", klass: "五班", events: ["400米", "1500米"] },
  
  # 800米参赛运动员（额外的）
  { number: "145", name: "张梦琪", klass: "四班", events: ["800米", "跳高"] },
  { number: "172", name: "董艺一", klass: "六班", events: ["800米", "跳远"] },
  { number: "121", name: "李盈秀", klass: "二班", events: ["800米", "跳远"] },
  
  # 1500米参赛运动员（额外的）
  { number: "132", name: "张雪娜", klass: "三班", events: ["1500米", "跳高"] },
  { number: "144", name: "刘慧轲", klass: "四班", events: ["1500米", "跳高"] },
  { number: "155", name: "支冰洋", klass: "五班", events: ["1500米", "跳远"] },
  { number: "171", name: "程欣怡", klass: "六班", events: ["1500米", "跳高"] },
  { number: "111", name: "谢安然", klass: "一班", events: ["1500米", "跳高"] },
  
  # 跳高参赛运动员（额外的）
  { number: "169", name: "高慧茹", klass: "六班", events: ["跳高", "跳远"] },
  
  # 跳远参赛运动员（额外的）
  { number: "143", name: "王亚茹", klass: "四班", events: ["跳远"] },
]

# 创建七年级运动员
puts "\n  📖 创建七年级运动员..."
grade_7 = grades["七年级"]

# 男子组
grade_7_male_athletes.each do |athlete_data|
  klass = grade_7.klasses.find_by(name: athlete_data[:klass])
  next unless klass
  
  athlete = klass.athletes.create!(
    name: athlete_data[:name],
    number: athlete_data[:number],
    gender: "男"
  )
  
  # 创建报名记录
  athlete_data[:events].each do |event_name|
    ce_key = "#{event_name}_男"
    ce = competition_events[ce_key]
    if ce
      athlete.athlete_competition_events.create!(competition_event: ce)
    end
  end
end

# 女子组
grade_7_female_athletes.each do |athlete_data|
  klass = grade_7.klasses.find_by(name: athlete_data[:klass])
  next unless klass
  
  athlete = klass.athletes.create!(
    name: athlete_data[:name],
    number: athlete_data[:number],
    gender: "女"
  )
  
  # 创建报名记录
  athlete_data[:events].each do |event_name|
    ce_key = "#{event_name}_女"
    ce = competition_events[ce_key]
    if ce
      athlete.athlete_competition_events.create!(competition_event: ce)
    end
  end
end

puts "  ✅ 七年级运动员创建完成"

# 创建八年级运动员
puts "\n  � 创建八年级运动员..."
grade_8 = grades["八年级"]

# 男子组
grade_8_male_athletes.each do |athlete_data|
  klass = grade_8.klasses.find_by(name: athlete_data[:klass])
  next unless klass
  
  athlete = klass.athletes.create!(
    name: athlete_data[:name],
    number: athlete_data[:number],
    gender: "男"
  )
  
  # 创建报名记录
  athlete_data[:events].each do |event_name|
    ce_key = "#{event_name}_男"
    ce = competition_events[ce_key]
    if ce
      athlete.athlete_competition_events.create!(competition_event: ce)
    end
  end
end

# 女子组
grade_8_female_athletes.each do |athlete_data|
  klass = grade_8.klasses.find_by(name: athlete_data[:klass])
  next unless klass
  
  athlete = klass.athletes.create!(
    name: athlete_data[:name],
    number: athlete_data[:number],
    gender: "女"
  )
  
  # 创建报名记录
  athlete_data[:events].each do |event_name|
    ce_key = "#{event_name}_女"
    ce = competition_events[ce_key]
    if ce
      athlete.athlete_competition_events.create!(competition_event: ce)
    end
  end
end

puts "  ✅ 八年级运动员创建完成"

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

# 按年级统计
puts "\n  七年级："
puts "    男生: #{Athlete.joins(klass: :grade).where(grades: { name: '七年级' }, gender: '男').count} 人"
puts "    女生: #{Athlete.joins(klass: :grade).where(grades: { name: '七年级' }, gender: '女').count} 人"
puts "  八年级："
puts "    男生: #{Athlete.joins(klass: :grade).where(grades: { name: '八年级' }, gender: '男').count} 人"
puts "    女生: #{Athlete.joins(klass: :grade).where(grades: { name: '八年级' }, gender: '女').count} 人"

puts "\n✨ 真实数据导入完成！"
puts "=" * 60
