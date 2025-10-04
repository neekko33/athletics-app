class CompetitionsController < ApplicationController
  before_action :set_competition, only: %i[ show edit update destroy]

  # GET /competitions or /competitions.json
  def index
    @competitions = Competition.all
  end

  # GET /competitions/1 or /competitions/1.json
  def show
    @competition = Competition.includes(
      grades: { klasses: :athletes },
      competition_events: :event,
      schedules: { heat: { competition_event: :event } }
    ).find(params[:id])
  end

  # GET /competitions/new
  def new
    @competition = Competition.new
  end

  # GET /competitions/1/edit
  def edit
  end

  # POST /competitions or /competitions.json
  def create
    @competition = Competition.new(competition_params)

    respond_to do |format|
      if @competition.save
        format.html { redirect_to @competition, notice: "运动会创建成功" }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /competitions/1 or /competitions/1.json
  def update
    respond_to do |format|
      if @competition.update(competition_params)
        format.html { redirect_to @competition, notice: "运动会更新成功", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1 or /competitions/1.json
  def destroy
    @competition.destroy!

    respond_to do |format|
      format.html { redirect_to competitions_path, notice: "运动会删除成功", status: :see_other }
    end
  end

  def add_event
    @competition = Competition.find(params.expect(:competition_id))
    @events = Event.all
    render :add_event
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_competition
      @competition = Competition.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def competition_params
      params.expect(competition: [ :name, :start_date, :end_date, :daily_start_time, :daily_end_time, :track_lanes ])
    end
end
