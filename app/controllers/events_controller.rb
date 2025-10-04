class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy]
  def index
    @events = Event.all
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to events_path, notice: "比赛项目创建成功"
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to events_path, notice: "比赛项目更新成功"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: "比赛项目删除成功"
  end

  private
  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.expect(event: [ :name, :event_type, :max_participants, :avg_time, :gender ])
  end
end
