class SchedulesController < ApplicationController
  before_action :set_competition
  before_action :set_schedule, only: [ :edit, :update, :destroy ]

  def index
    @schedules = @competition.schedules
                            .includes(heat: { competition_event: :event, grade: nil, lanes: { lane_athletes: :athlete } })
                            .order(:scheduled_at)

    # 按日期分组
    @schedules_by_date = @schedules.group_by { |s| s.scheduled_at.to_date }
                                   .sort_by { |date, _| date }

    @heats_without_schedule = Heat.joins(competition_event: :competition)
                                  .where(competition_events: { competition_id: @competition.id })
                                  .where.not(id: @competition.schedules.pluck(:heat_id))
                                  .includes(competition_event: :event)

    # 获取所有年级和班级数据（用于格式化日程）
    @grades = @competition.grades.includes(klasses: { athletes: :athlete_competition_events })
                          .order(:order)
  end

  def new
    @schedule = Schedule.new
    @heat = Heat.find(params[:heat_id]) if params[:heat_id]
    @available_heats = Heat.joins(competition_event: :competition)
                          .where(competition_events: { competition_id: @competition.id })
                          .where.not(id: @competition.schedules.pluck(:heat_id))
                          .includes(competition_event: :event)
  end

  def create
    @schedule = Schedule.new(schedule_params)

    if @schedule.save
      redirect_to competition_schedules_path(@competition), notice: "日程添加成功"
    else
      @available_heats = Heat.joins(competition_event: :competition)
                            .where(competition_events: { competition_id: @competition.id })
                            .where.not(id: @competition.schedules.pluck(:heat_id))
                            .includes(competition_event: :event)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @available_heats = Heat.joins(competition_event: :competition)
                          .where(competition_events: { competition_id: @competition.id })
                          .where("heats.id = ? OR heats.id NOT IN (?)", @schedule.heat_id, @competition.schedules.pluck(:heat_id))
                          .includes(competition_event: :event)
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to competition_schedules_path(@competition), notice: "日程更新成功"
    else
      @available_heats = Heat.joins(competition_event: :competition)
                            .where(competition_events: { competition_id: @competition.id })
                            .where("heats.id = ? OR heats.id NOT IN (?)", @schedule.heat_id, @competition.schedules.pluck(:heat_id))
                            .includes(competition_event: :event)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule.destroy
    redirect_to competition_schedules_path(@competition), notice: "日程已删除"
  end

  def reorder
    params[:schedules].each_with_index do |schedule_id, index|
      Schedule.find(schedule_id).update(display_order: index + 1)
    end
    head :ok
  end

  # 批量添加日程的页面
  def bulk_new
    # 获取所有未安排的项目(competition_event)
    scheduled_heat_ids = @competition.schedules.pluck(:heat_id)

    # 获取所有未安排的heats
    query = Heat.joins(competition_event: :competition)
                .joins(:grade)
                .joins("INNER JOIN events ON events.id = competition_events.event_id")
                .where(competition_events: { competition_id: @competition.id })

    # 只有当有已安排的heats时才添加排除条件
    query = query.where.not(id: scheduled_heat_ids) if scheduled_heat_ids.present?

    unscheduled_heats = query.select("heats.*",
                                     "grades.id as grade_id",
                                     "grades.name as grade_name",
                                     'grades."order" as grade_order',
                                     "events.id as event_id",
                                     "events.name as event_name",
                                     "events.gender as event_gender",
                                     "events.avg_time as event_avg_time")
                             .order('grades."order"', "events.name", "heats.heat_number")

    # 按年级、项目、性别分组
    @grouped_heats = unscheduled_heats.group_by do |heat|
      {
        grade_id: heat.grade_id,
        grade_name: heat.grade_name,
        event_id: heat.event_id,
        event_name: heat.event_name,
        gender: heat.event_gender,
        avg_time: heat.event_avg_time
      }
    end
  end

  # 批量创建日程
  def bulk_create
    grade_id = params[:grade_id]
    event_id = params[:event_id]
    gender = params[:gender]
    start_date = params[:start_date]
    start_time = params[:start_time]
    venue = params[:venue]
    notes = params[:notes]
    avg_time = params[:avg_time].to_i

    # 查找符合条件的未安排heats
    scheduled_heat_ids = @competition.schedules.pluck(:heat_id)
    query = Heat.joins(competition_event: :competition)
                .joins(:grade)
                .joins("INNER JOIN events ON events.id = competition_events.event_id")
                .where(competition_events: { competition_id: @competition.id })
                .where(grades: { id: grade_id })
                .where(events: { id: event_id, gender: gender })

    # 只有当有已安排的heats时才添加排除条件
    query = query.where.not(id: scheduled_heat_ids) if scheduled_heat_ids.present?

    heats = query.order("heats.heat_number")

    if heats.empty?
      redirect_to competition_schedules_path(@competition), alert: "没有可安排的分组" and return
    end

    # 解析开始时间
    begin
      start_datetime = Time.zone.parse("#{start_date} #{start_time}")
    rescue
      redirect_to bulk_new_competition_schedules_path(@competition),
                  alert: "时间格式错误" and return
    end

    created_count = 0
    current_time = start_datetime

    Schedule.transaction do
      heats.each do |heat|
        schedule = Schedule.new(
          heat: heat,
          scheduled_at: current_time,
          end_at: current_time + avg_time.minutes,
          venue: venue,
          notes: notes
        )

        if schedule.save
          created_count += 1
          current_time += avg_time.minutes
        else
          raise ActiveRecord::Rollback
        end
      end
    end

    if created_count == heats.count
      grade = Grade.find(grade_id)
      event = Event.find(event_id)
      redirect_to competition_schedules_path(@competition),
                  notice: "成功为 #{grade.name} #{event.name} (#{gender}) 添加了 #{created_count} 个日程"
    else
      redirect_to bulk_new_competition_schedules_path(@competition),
                  alert: "批量添加失败,请检查时间冲突"
    end
  end

  # 打印版日程表
  def print
    @schedules = @competition.schedules
                            .includes(heat: { competition_event: :event, grade: nil, lanes: { lane_athletes: :athlete } })
                            .order(:scheduled_at)

    # 按日期分组
    @schedules_by_date = @schedules.group_by { |s| s.scheduled_at.to_date }
                                   .sort_by { |date, _| date }

    # 获取所有年级和班级数据（用于班级名单）
    @grades = @competition.grades.includes(klasses: { athletes: :athlete_competition_events })
                          .order(:order)

    render layout: "print"
  end

  private
  def set_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def schedule_params
    params.require(:schedule).permit(:heat_id, :scheduled_at, :end_at, :venue, :notes)
  end
end
