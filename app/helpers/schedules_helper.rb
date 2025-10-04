module SchedulesHelper
  # 将阿拉伯数字转换为中文数字
  def number_to_chinese(number)
    chinese_numbers = {
      "0" => "零", "1" => "一", "2" => "二", "3" => "三", "4" => "四",
      "5" => "五", "6" => "六", "7" => "七", "8" => "八", "9" => "九",
      "10" => "十", "11" => "十一", "12" => "十二"
    }

    chinese_numbers[number.to_s] || number.to_s
  end

  # 将班级名称中的数字转换为中文
  # 例如: "1班" -> "一班", "2班" -> "二班"
  def class_name_to_chinese(class_name)
    return class_name unless class_name

    # 匹配 "数字班" 格式
    if class_name =~ /^(\d+)班$/
      number = $1
      return "#{number_to_chinese(number)}班"
    end

    # 如果已经是中文格式，直接返回
    class_name
  end
end
