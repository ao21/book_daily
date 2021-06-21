class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]

  def index
    @tasks = current_user.tasks.all.order(finished_on: :desc)
    @progress_data = Task.progress_data(@tasks)
  end

  def show
    @reads = @task.reads.all.order(read_on: :desc)
    @progress_data = JSON.parse params[:data]
  end

  def new
    @book = Book.find_by(id: params[:book_id])
    @task = Task.new
  end

  def create
    @book = Book.find_by(id: params[:book_id])
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "目標を登録しました"
    else
      flash.now[:alert] = "目標の登録に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @task.destroy!
    redirect_to tasks_path, alert: "削除しました"
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:started_on, :finished_on, :user_id).merge(book_id: params[:book_id])
  end
end
