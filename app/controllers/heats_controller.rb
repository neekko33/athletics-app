class HeatsController < ApplicationController
  before_action :set_competition

  def index
    @track_events = @competition.competition_events
                                .joins(:event)
                                .where(events: { event_type: "track" })
                                .includes(:event, heats: { lanes: { lane_athletes: :athlete } })

    @field_events = @competition.competition_events
                                .joins(:event)
                                .where(events: { event_type: "field" })
                                .includes(:event, heats: { lanes: { lane_athletes: :athlete } })
  end

  def generate_all
    # 为所有径赛项目生成分组
    track_events = @competition.competition_events
                              .joins(:event)
                              .where(events: { event_type: "track" })
                              .includes(:event, athlete_competition_events: { athlete: { klass: :grade } })

    generated_count = 0
    errors = []
    warnings = []

    track_events.each do |competition_event|
      # 清除旧的分组
      competition_event.heats.destroy_all

      # 获取所有报名的运动员，按年级分组
      athletes = competition_event.athlete_competition_events
                                 .includes(athlete: { klass: :grade })
                                 .map(&:athlete)

      next if athletes.empty?

      # 检查是否是接力项目
      is_relay = competition_event.event.name.include?("接力") || competition_event.event.name.include?("4*100")
      max_lanes = @competition.track_lanes

      if is_relay
        # 接力项目：按年级→班级分组，每个班级4人
        athletes_by_grade = athletes.group_by { |a| a.klass.grade }

        athletes_by_grade.each do |grade, grade_athletes|
          # 按班级分组
          athletes_by_klass = grade_athletes.group_by(&:klass)

          valid_teams = []
          insufficient_teams = []

          athletes_by_klass.each do |klass, klass_athletes|
            if klass_athletes.count >= 4
              valid_teams << { klass: klass, athletes: klass_athletes }
            else
              insufficient_teams << "#{grade.name} #{klass.name} 只有#{klass_athletes.count}人（需要4人）"
            end
          end

          if insufficient_teams.any?
            warnings << "#{competition_event.event.name} - #{insufficient_teams.join('; ')}"
          end

          # 为有效队伍创建分组
          unless valid_teams.empty?
            heat_count = (valid_teams.count.to_f / max_lanes).ceil

            heat_count.times do |i|
              heat_teams = valid_teams.slice(i * max_lanes, max_lanes)
              next if heat_teams.empty?

              heat = competition_event.heats.create!(
                grade: grade,
                heat_number: i + 1,
                total_lanes: max_lanes
              )

              heat_teams.each_with_index do |team, lane_index|
                lane = heat.lanes.create!(lane_number: lane_index + 1)

                # 随机选择4名运动员
                team[:athletes].shuffle.first(4).each_with_index do |athlete, position|
                  lane.lane_athletes.create!(
                    athlete: athlete,
                    relay_position: position + 1
                  )
                end
              end

              generated_count += 1
            end
          end
        end
      else
        # 非接力项目：先按年级分组，年级内如果人数超过赛道数则再次分组
        athletes_by_grade = athletes.group_by { |a| a.klass.grade }

        athletes_by_grade.each do |grade, grade_athletes|
          # 随机打乱年级内的运动员
          shuffled_athletes = grade_athletes.shuffle

          # 计算需要多少个分组
          heat_count = (shuffled_athletes.count.to_f / max_lanes).ceil

          heat_count.times do |i|
            heat_athletes = shuffled_athletes.slice(i * max_lanes, max_lanes)
            next if heat_athletes.empty?

            heat = competition_event.heats.create!(
              grade: grade,
              heat_number: i + 1,
              total_lanes: max_lanes
            )

            # 从1号赛道开始连续分配
            heat_athletes.each_with_index do |athlete, index|
              lane = heat.lanes.create!(lane_number: index + 1)
              lane.lane_athletes.create!(athlete: athlete)
            end

            generated_count += 1
          end
        end
      end
    end

    if warnings.any?
      flash[:warning] = "生成完成，但有以下警告：<br/>#{warnings.join('<br/>')}".html_safe
    end

    if generated_count > 0
      redirect_to competition_heats_path(@competition), notice: "成功生成 #{generated_count} 个比赛分组"
    else
      redirect_to competition_heats_path(@competition), alert: "未能生成任何分组。#{errors.join('; ')}"
    end
  end

  def generate_field_events
    # 为所有田赛项目生成分组
    field_events = @competition.competition_events
                              .joins(:event)
                              .where(events: { event_type: "field" })
                              .includes(:event, athlete_competition_events: { athlete: { klass: :grade } })

    generated_count = 0

    field_events.each do |competition_event|
      # 清除旧的分组
      competition_event.heats.destroy_all

      # 获取所有报名的运动员，按年级分组
      athletes = competition_event.athlete_competition_events
                                 .includes(athlete: { klass: :grade })
                                 .map(&:athlete)

      next if athletes.empty?

      # 田赛项目：按年级分组，不限人数
      athletes_by_grade = athletes.group_by { |a| a.klass.grade }

      athletes_by_grade.each do |grade, grade_athletes|
        # 随机打乱年级内的运动员顺序
        shuffled_athletes = grade_athletes.shuffle

        # 为该年级创建一个分组
        heat = competition_event.heats.create!(
          grade: grade,
          heat_number: 1,  # 田赛每个年级只有一组
          total_lanes: shuffled_athletes.count  # 人数即为总位置数
        )

        # 为每个运动员分配位置
        shuffled_athletes.each_with_index do |athlete, index|
          lane = heat.lanes.create!(
            lane_number: index + 1,  # 仍然需要lane_number作为分组标识
            position: index + 1       # position表示试跳/试投顺序
          )
          lane.lane_athletes.create!(athlete: athlete)
        end

        generated_count += 1
      end
    end

    redirect_to competition_heats_path(@competition), notice: "成功生成 #{generated_count} 个田赛分组"
  end

  def show
    @heat = Heat.find(params[:id])
    @competition_event = @heat.competition_event
  end

  def edit
    @heat = Heat.find(params[:id])
    @competition_event = @heat.competition_event

    # 获取同项目、同性别、同年级的其他分组中的运动员
    @available_athletes = Athlete.joins(lane_athletes: { lane: :heat })
                                  .joins(klass: :grade)
                                  .where(heats: {
                                    competition_event_id: @competition_event.id,
                                    grade_id: @heat.grade_id
                                  })
                                  .where.not(heats: { id: @heat.id })
                                  .includes(klass: :grade, lane_athletes: { lane: :heat })
                                  .distinct
                                  .order(Arel.sql('COALESCE("grades"."order", 999), klasses.name'))

    # 获取已报名但未分组的运动员（同年级）
    # 先获取已报名该项目的所有运动员ID
    registered_athlete_ids = @competition_event.athlete_competition_events
                                                .joins(athlete: { klass: :grade })
                                                .where(grades: { id: @heat.grade_id })
                                                .pluck(:athlete_id)

    # 获取已经在分组中的运动员ID
    grouped_athlete_ids = Athlete.joins(lane_athletes: { lane: :heat })
                                  .where(heats: {
                                    competition_event_id: @competition_event.id,
                                    grade_id: @heat.grade_id
                                  })
                                  .pluck(:id)

    # 未分组的运动员ID = 已报名 - 已分组
    ungrouped_athlete_ids = registered_athlete_ids - grouped_athlete_ids

    @ungrouped_athletes = Athlete.where(id: ungrouped_athlete_ids)
                                  .joins(klass: :grade)
                                  .includes(klass: :grade)
                                  .order(Arel.sql('COALESCE("grades"."order", 999), klasses.name'))
  end

  def update
    @heat = Heat.find(params[:id])
    @competition_event = @heat.competition_event

    # 处理运动员操作
    if params[:action_type] == "add_athlete"
      add_athlete_to_heat
      return
    elsif params[:action_type] == "remove_athlete"
      remove_athlete_from_heat
      return
    end

    # 普通更新
    if @heat.update(heat_params)
      redirect_to competition_heat_path(@competition, @heat), notice: "分组信息更新成功"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @heat = Heat.find(params[:id])
    @heat.destroy
    redirect_to competition_heats_path(@competition), notice: "分组已删除"
  end

  private
  def set_competition
    @competition = Competition.find(params[:competition_id])
  end

  def heat_params
    params.require(:heat).permit(:heat_number, :total_lanes)
  end

  def add_athlete_to_heat
    athlete_id = params[:athlete_id]
    lane_number = params[:lane_number]
    relay_position = params[:relay_position] # 接力项目的棒次

    if athlete_id.blank? || lane_number.blank?
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "请选择运动员和赛道"
      return
    end

    athlete = Athlete.find(athlete_id)
    is_relay = @competition_event.event.name.include?("接力") || @competition_event.event.name.include?("4*100")

    # 检查年级是否匹配
    if @heat.grade_id && athlete.klass.grade_id != @heat.grade_id
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "该运动员年级与当前分组不符"
      return
    end

    # 检查该运动员是否已经在当前分组中
    if @heat.athletes.include?(athlete)
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "该运动员已经在当前分组中"
      return
    end

    # 非接力项目：检查该赛道是否已被占用
    if !is_relay && @heat.lanes.exists?(lane_number: lane_number)
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "该赛道已被占用"
      return
    end

    # 接力项目：检查棒次参数
    if is_relay && relay_position.blank?
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "接力项目需要指定棒次"
      return
    end

    # 接力项目：检查该赛道的该棒次是否已被占用
    if is_relay
      lane = @heat.lanes.find_by(lane_number: lane_number)
      if lane && lane.lane_athletes.exists?(relay_position: relay_position)
        redirect_to edit_competition_heat_path(@competition, @heat), alert: "该赛道的第#{relay_position}棒已被占用"
        return
      end
    end

    Heat.transaction do
      # 从原分组中移除该运动员（如果存在）
      old_lane_athlete = LaneAthlete.joins(:lane)
                                     .where(athlete_id: athlete_id)
                                     .where(lanes: {
                                       heat_id: Heat.joins(:competition_event)
                                                    .where(competition_events: {
                                                      id: @heat.competition_event_id
                                                    })
                                                    .pluck(:id)
                                     })
                                     .first

      if old_lane_athlete
        old_lane = old_lane_athlete.lane
        old_lane_athlete.destroy

        # 如果旧赛道没有其他运动员了，删除该赛道
        if old_lane.lane_athletes.empty?
          old_lane.destroy
        end
      end

      # 添加到新分组
      lane = @heat.lanes.find_or_create_by!(lane_number: lane_number)

      if is_relay
        lane.lane_athletes.create!(athlete: athlete, relay_position: relay_position)
      else
        lane.lane_athletes.create!(athlete: athlete)
      end
    end

    if is_relay
      redirect_to edit_competition_heat_path(@competition, @heat), notice: "运动员已添加到第 #{lane_number} 赛道第 #{relay_position} 棒"
    else
      redirect_to edit_competition_heat_path(@competition, @heat), notice: "运动员已添加到第 #{lane_number} 赛道"
    end
  rescue => e
    redirect_to edit_competition_heat_path(@competition, @heat), alert: "添加失败：#{e.message}"
  end

  def remove_athlete_from_heat
    athlete_id = params[:athlete_id]

    if athlete_id.blank?
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "请选择要移除的运动员"
      return
    end

    lane_athlete = LaneAthlete.joins(:lane)
                               .where(athlete_id: athlete_id)
                               .where(lanes: { heat_id: @heat.id })
                               .first

    if lane_athlete.nil?
      redirect_to edit_competition_heat_path(@competition, @heat), alert: "该运动员不在当前分组中"
      return
    end

    Heat.transaction do
      lane = lane_athlete.lane
      lane_athlete.destroy

      # 如果赛道没有其他运动员了，删除该赛道
      if lane.lane_athletes.empty?
        lane.destroy
      end
    end

    redirect_to edit_competition_heat_path(@competition, @heat), notice: "运动员已从分组中移除"
  rescue => e
    redirect_to edit_competition_heat_path(@competition, @heat), alert: "移除失败：#{e.message}"
  end
end
