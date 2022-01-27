class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: %i[show edit update destroy]

  def today
    @tasks = Task.array_tasks_in_progress(current_user)
    @tasks.each_with_index do |task, i|
      val = "@target#{i}"
      eval("#{val} = Task.today_data(task)")
    end
  end

  def index
    @tasks = current_user.tasks.all.order(finished_on: :desc)
    @reads = current_user.reads
    @tasks_percentage = Task.tasks_percentage(@tasks)
    @month_data = Read.month_data(current_user)
  end

  def show
    @task_percentage = Task.task_percentage(@task)
    @reads = @task.reads.all.order(up_to_page: :desc)
    @reads_percentage = Read.reads_percentage(@reads, @task)
  end

  def new
    @book = Book.find_by(id: params[:book_id])
    @task = Task.new
  end

  def create
    @book = Book.find_by(id: params[:book_id])
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to today_tasks_path, notice: "目標を登録しました"
    else
      flash.now[:alert] = "目標の登録に失敗しました"
      render :new
    end
  end

  def edit
    @book = @task.book
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "目標を更新しました"
    else
      flash.now[:alert] = "目標の更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @task.destroy!
    redirect_to tasks_path, alert: "目標を削除しました"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:started_on, :finished_on, :user_id).merge(book_id: params[:book_id])
  end
end
