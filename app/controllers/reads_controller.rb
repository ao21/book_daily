class ReadsController < ApplicationController
  before_action :set_task

  def new
    if params
      @read = Read.new(read_on: params[:read_on])
    else
      @read = Read.new
    end
    session[:previous_url] = request.referer
  end

  def create
    @read = @task.reads.build(read_params)
    if @read.save
      if session[:previous_url]
        redirect_to session[:previous_url], notice: "進捗を登録しました"
      else
        redirect_to today_tasks_path, notice: "進捗を登録しました"
      end
    else
      flash.now[:alert] = "進捗の登録に失敗しました。"
      render :new
    end
  end

  def destroy
    @read = @task.reads.find(params[:id])
    @read.destroy!
    redirect_to task_path(@task.id), alert: "削除しました"
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def read_params
    params.require(:read).permit(:read_on, :up_to_page)
  end
end
