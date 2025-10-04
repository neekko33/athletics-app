class SchedulesController < ApplicationController
  before_action :set_competition
  before_action :set_schedule, only: [ :edit, :update, :destroy ]

  def index
    @schedules = @competition.schedules
                            .includes(heat: { competition_event: :event })
                            .order(:scheduled_at)
    @heats_without_schedule = Heat.joins(competition_event: :competition)
                                  .where(competition_events: { competition_id: @competition.id })
                                  .where.not(id: @competition.schedules.pluck(:heat_id))
                                  .includes(competition_event: :event)
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
                          .where("id = ? OR id NOT IN (?)", @schedule.heat_id, @competition.schedules.pluck(:heat_id))
                          .includes(competition_event: :event)
  end

  def update
    if @schedule.update(schedule_params)
      redirect_to competition_schedules_path(@competition), notice: "日程更新成功"
    else
      @available_heats = Heat.joins(competition_event: :competition)
                            .where(competition_events: { competition_id: @competition.id })
                            .where("id = ? OR id NOT IN (?)", @schedule.heat_id, @competition.schedules.pluck(:heat_id))
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
