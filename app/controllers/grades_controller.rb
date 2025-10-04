class GradesController < ApplicationController
  before_action :set_competition
  before_action :set_grade, only: [ :edit, :update, :destroy ]
  def index
    @grades = @competition.grades
  end

  def new
    @grade = @competition.grades.new
  end

  def create
    @grade = @competition.grades.new(grade_params)
    @grade.order = @competition.grades.count + 1
    if @grade.save
      redirect_to competition_grades_path(@competition), notice: "年级创建成功"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @grade.update(grade_params)
      redirect_to competition_grades_path(@competition), notice: "年级更新成功"
    else
      render :edit
    end
  end

  def destroy
    @grade.destroy
    redirect_to competition_grades_path(@competition), notice: "年级删除成功"
  end

  private
  def set_competition
    @competition = Competition.find(params[:competition_id])
  end

  def set_grade
    @grade = @competition.grades.find_by(id: params[:id])
  end

  def grade_params
    params.expect(grade: [ :name ])
  end
end
