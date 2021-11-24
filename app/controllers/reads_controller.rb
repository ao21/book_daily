class ReadsController < ApplicationController
  before_action :set_task
  before_action :set_read, only: %i[edit update destroy]

  def new
    if params
      @read = Read.new(read_on: params[:read_on])
    else
      @read = Read.new
    end
  end

  def create
    @read = @task.reads.build(read_params)
    if @read.save
      redirect_to today_tasks_path, notice: "進捗を登録しました。"
    else
      flash.now[:alert] = "進捗の登録に失敗しました。"
      render :new
    end
  end

  def edit
  end

  def update
    if @read.update(read_params)
      redirect_to task_path(@task.id), notice: "更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @read.destroy!
    redirect_to task_path(@task.id), alert: "削除しました"
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_read
    @read = @task.reads.find(params[:id])
  end

  def read_params
    params.require(:read).permit(:read_on, :up_to_page)
  end
end
