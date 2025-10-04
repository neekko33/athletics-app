class AthletesController < ApplicationController
  before_action :set_competition
  before_action :set_grade, only: [ :new ]
  before_action :set_athlete, only: [ :edit, :update, :destroy ]

  def index
    @grades = @competition.grades.includes(:athletes)
  end

  def new
    @athlete = @grade.athletes.new
    @events = Event.all
  end

  def edit
    @grade = @athlete.klass.grade
    @events = Event.all
  end

  def create
    # 动态查找或创建班级
    klass_name = params[:athlete][:klass_name]
    grade = @competition.grades.find_by(id: params[:athlete][:grade_id])

    klass = grade.klasses.find_or_create_by!(name: klass_name) do |k|
      # 自动设置排序顺序（提取班级号）
      if klass_name =~ /(\d+)/
        k.order = $1.to_i
      else
        k.order = grade.klasses.maximum(:order).to_i + 1
      end
    end

    # 创建运动员
    @athlete = klass.athletes.new(athlete_params.except(:event_ids, :klass_name))

    if @athlete.save
      # 动态创建 CompetitionEvent 并关联到运动员
      if params[:athlete][:event_ids].present?
        event_ids = params[:athlete][:event_ids].reject(&:blank?)
        event_ids.each do |event_id|
          # 查找或创建 CompetitionEvent
          competition_event = @competition.competition_events.find_or_create_by!(event_id: event_id)
          # 创建运动员与比赛项目的关联
          @athlete.athlete_competition_events.create!(competition_event: competition_event)
        end
      end
      redirect_to competition_athletes_path(@competition), notice: "运动员添加成功"
    else
      @events = Event.all
      flash.now[:alert] = "运动员添加失败：#{@athlete.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @events = Event.all
    flash.now[:alert] = "操作失败：#{e.message}"
    render :new, status: :unprocessable_entity
  end

  def update
    klass_name = params[:athlete][:klass_name]
    grade = @athlete.klass.grade

    # 查找或创建班级
    klass = grade.klasses.find_or_create_by!(name: klass_name) do |k|
      if klass_name =~ /(\d+)/
        k.order = $1.to_i
      else
        k.order = grade.klasses.maximum(:order).to_i + 1
      end
    end

    # 更新运动员基本信息
    if @athlete.update(athlete_params.except(:event_ids, :klass_name))
      # 更新班级关联
      @athlete.update(klass: klass) if @athlete.klass != klass

      # 更新报名项目
      if params[:athlete][:event_ids].present?
        # 删除旧的关联
        @athlete.athlete_competition_events.destroy_all

        # 创建新的关联
        event_ids = params[:athlete][:event_ids].reject(&:blank?)
        event_ids.each do |event_id|
          competition_event = @competition.competition_events.find_or_create_by!(event_id: event_id)
          @athlete.athlete_competition_events.create!(competition_event: competition_event)
        end
      end

      redirect_to competition_athletes_path(@competition), notice: "运动员信息更新成功"
    else
      @grade = grade
      @events = Event.all
      flash.now[:alert] = "运动员更新失败：#{@athlete.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordInvalid => e
    @grade = grade
    @events = Event.all
    flash.now[:alert] = "操作失败：#{e.message}"
    render :edit, status: :unprocessable_entity
  end

  def destroy
    @athlete.destroy
    redirect_to competition_athletes_path(@competition), notice: "运动员已删除"
  end

  def generate_numbers
    # 按年级 -> 班级 -> 性别(男->女)排序，生成编号
    athletes = @competition.grades.includes(klasses: :athletes)
                          .order(:order)
                          .flat_map do |grade|
      grade.klasses.order(:order).flat_map do |klass|
        # 先男生，后女生
        klass.athletes.order(Arel.sql("CASE WHEN gender = '男' THEN 0 WHEN gender = '女' THEN 1 END"))
      end
    end

    athletes.each_with_index do |athlete, index|
      athlete.update_column(:number, format("%03d", index + 1))
    end

    redirect_to competition_athletes_path(@competition), notice: "运动员编号生成成功！共生成 #{athletes.count} 个编号"
  end

  def import
    unless params[:file].present?
      redirect_to competition_athletes_path(@competition), alert: "请选择要导入的Excel文件"
      return
    end

    file = params[:file]
    begin
      spreadsheet = Roo::Spreadsheet.open(file.path)
      header = spreadsheet.row(1)
      imported_count = 0
      errors = []

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[ header, spreadsheet.row(i) ].transpose]

        # 查找年级
        grade = @competition.grades.find_by(name: row["年级"])
        unless grade
          errors << "第#{i}行: 找不到年级 '#{row["年级"]}'"
          next
        end

        # 查找或创建班级
        klass = grade.klasses.find_or_create_by!(name: row["班级"]) do |k|
          if row["班级"] =~ /(\d+)/
            k.order = $1.to_i
          else
            k.order = grade.klasses.maximum(:order).to_i + 1
          end
        end

        # 创建运动员
        athlete = klass.athletes.create(
          name: row["姓名"],
          gender: row["性别"]
        )

        if athlete.persisted?
          # 处理报名项目（如果有）
          if row["报名项目"].present?
            event_names = row["报名项目"].to_s.split(/[,，、]/).map(&:strip)
            event_names.each do |event_name|
              event = Event.find_by(name: event_name, gender: row["性别"])
              if event
                  # 验证性别是否匹配
                  competition_event = @competition.competition_events.find_or_create_by!(event_id: event.id)
                  athlete.athlete_competition_events.create!(competition_event: competition_event)
              else
                errors << "第#{i}行: 找不到项目 '#{event_name}'"
              end
            end
          end
          imported_count += 1
        else
          errors << "第#{i}行: #{athlete.errors.full_messages.join(', ')}"
        end
      end

      if errors.any?
        flash[:alert] = "导入完成，成功 #{imported_count} 条，失败 #{errors.count} 条。错误详情：#{errors.join('; ')}"
      else
        flash[:notice] = "成功导入 #{imported_count} 名运动员"
      end
    rescue => e
      flash[:alert] = "导入失败: #{e.message}"
    end

    redirect_to competition_athletes_path(@competition)
  end

  def download_template
    require "csv"

    # 获取当前比赛的年级列表
    grades = @competition.grades.order(:order).pluck(:name)

    # 创建 CSV 数据
    csv_data = CSV.generate(encoding: "UTF-8", write_headers: true, headers: [ "年级", "班级", "姓名", "性别", "报名项目" ]) do |csv|
      # 添加说明行（用注释）
      csv << [ "# 请删除此说明行", "填写示例如下", "↓↓↓", "", "" ]

      # 添加示例数据
      if grades.any?
        first_grade = grades.first
        csv << [ first_grade, "1班", "张三", "男", "100米,跳远" ]
        csv << [ first_grade, "1班", "李四", "女", "100米,200米" ]
        csv << [ first_grade, "2班", "王五", "男", "400米,跳高" ]

        if grades.length > 1
          second_grade = grades[1]
          csv << [ second_grade, "1班", "赵六", "女", "200米" ]
        end
      else
        # 如果没有年级，使用通用示例
        csv << [ "一年级", "1班", "张三", "男", "100米,跳远" ]
        csv << [ "一年级", "1班", "李四", "女", "100米,200米" ]
        csv << [ "二年级", "2班", "王五", "男", "400米" ]
      end
    end

    # 发送文件
    send_data "\uFEFF" + csv_data,  # 添加 BOM 以支持 Excel 正确识别 UTF-8
              filename: "运动员导入模板_#{@competition.name}_#{Time.current.strftime('%Y%m%d')}.csv",
              type: "text/csv; charset=utf-8",
              disposition: "attachment"
  end

  private
  def set_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_athlete
    @athlete = Athlete.find(params[:id])
  end

  def set_grade
    @grade = @competition.grades.find_by(id: params[:grade_id])
  end

  def athlete_params
    params.require(:athlete).permit(:name, :gender, :klass_name, event_ids: [])
  end
end
