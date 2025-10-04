class AthletesController < ApplicationController
  before_action :set_competition
  def index
    @athletes = @competition.athletes
  end

  def new
    @athlete = @competition.athletes.new
    @events = Event.all
  end

  def create
    @athlete = @competition.athletes.new(athlete_params.except(:event_ids))

    if @athlete.save
      # 动态创建 CompetitionEvent 并关联到运动员
      if params[:athlete][:event_ids].present?
        event_ids = params[:athlete][:event_ids].reject(&:blank?)
        event_ids.each do |event_id|
          # 查找或创建 CompetitionEvent
          competition_event = @competition.competition_events.find_or_create_by(event_id: event_id)
          # 创建运动员与比赛项目的关联
          @athlete.athlete_competition_events.create(competition_event: competition_event)
        end
      end
      redirect_to competition_athletes_path(@competition), notice: "运动员添加成功"
    else
      @events = Event.all
      render :new
    end
  end

  private
  def set_competition
    @competition = Competition.find(params[:competition_id])
  end

  def athlete_params
    params.require(:athlete).permit(:name, :grade_name, :class_name, event_ids: [])
  end
end
