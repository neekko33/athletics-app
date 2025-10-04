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
      is_relay = competition_event.event.name.include?("接力") || competition_event.event.name.include?("4x100")
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
  end

  def update
    @heat = Heat.find(params[:id])
    if @heat.update(heat_params)
      redirect_to competition_heat_path(@competition, @heat), notice: "分组信息更新成功"
    else
      @competition_event = @heat.competition_event
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
end
