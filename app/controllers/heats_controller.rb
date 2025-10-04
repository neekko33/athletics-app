class HeatsController < ApplicationController
  before_action :set_competition

  def index
    @track_events = @competition.competition_events
                                .joins(:event)
                                .where(events: { event_type: "track" })
                                .includes(:event, heats: { lanes: { lane_athletes: :athlete } })
  end

  def generate_all
    # 为所有径赛项目生成分组
    track_events = @competition.competition_events
                              .joins(:event)
                              .where(events: { event_type: "track" })
                              .includes(:event, athlete_competition_events: :athlete)

    generated_count = 0
    track_events.each do |competition_event|
      # 清除旧的分组
      competition_event.heats.destroy_all

      # 获取所有报名的运动员
      athletes = competition_event.athlete_competition_events
                                 .includes(:athlete)
                                 .map(&:athlete)

      next if athletes.empty?

      # 检查是否是接力项目
      is_relay = competition_event.event.name.include?("接力")
      max_lanes = @competition.track_lanes # 使用比赛设置的跑道数量

      if is_relay
        # 接力项目：4人一组，按班级分组
        athletes_by_klass = athletes.group_by(&:klass)

        athletes_by_klass.each_with_index do |(klass, klass_athletes), index|
          next if klass_athletes.count < 4 # 接力需要至少4人

          heat = competition_event.heats.create!(
            heat_number: index + 1,
            total_lanes: max_lanes
          )

          # 随机分配一个赛道（1到max_lanes之间）
          lane_number = rand(1..max_lanes)
          lane = heat.lanes.create!(lane_number: lane_number)

          # 分配4名运动员到这个赛道
          klass_athletes.shuffle.first(4).each_with_index do |athlete, position|
            lane.lane_athletes.create!(
              athlete: athlete,
              relay_position: position + 1
            )
          end

          generated_count += 1
        end
      else
        # 非接力项目：按报名顺序随机打乱，每组最多max_lanes人
        shuffled_athletes = athletes.shuffle
        heat_count = (shuffled_athletes.count.to_f / max_lanes).ceil

        heat_count.times do |i|
          heat_athletes = shuffled_athletes.slice(i * max_lanes, max_lanes)
          next if heat_athletes.empty?

          heat = competition_event.heats.create!(
            heat_number: i + 1,
            total_lanes: max_lanes
          )

          # 随机分配连续的赛道
          lanes_count = heat_athletes.count
          start_lane = rand(1..(max_lanes - lanes_count + 1))
          lane_numbers = (start_lane...(start_lane + lanes_count)).to_a.shuffle

          heat_athletes.each_with_index do |athlete, index|
            lane = heat.lanes.create!(lane_number: lane_numbers[index])
            lane.lane_athletes.create!(athlete: athlete)
          end

          generated_count += 1
        end
      end
    end

    redirect_to competition_heats_path(@competition), notice: "成功生成 #{generated_count} 个比赛分组"
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
