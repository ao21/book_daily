class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only: %i[show edit update destroy]
  before_action :side_bar, only: %i[index show]
  
  def side_bar
    @reads = current_user.reads
    @month_data = Read.month_data(current_user)
  end

  def today
    @tasks = Task.array_tasks_in_progress(current_user)
    @tasks.each_with_index do |task, i|
      val = "@target#{i}"
      eval("#{val} = Task.todays_page_data(task)")
    end
  end

  def index
    @tasks = current_user.tasks.all.order(finished_on: :desc)
    @progress_data = Task.progress_data(@tasks)
  end

  def show
    @reads = @task.reads.all.order(read_on: :desc)
    @task_progress_data = Task.task_progress_data(@task)
    @progress_percentage = { read: @task_progress_data[0][:percentage], unread: 100 - @task_progress_data[0][:percentage] }
  end

  def new
    @book = Book.find_by(id: params[:book_id])
    @task = Task.new
  end

  def create
    @book = Book.find_by(id: params[:book_id])
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to @task, notice: "目標を登録しました"
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

  def correct_user
    @task = Task.find(params[:id])
    unless @task.user.id == current_user.id
      redirect_to tasks_path
    end
  end

  def task_params
    params.require(:task).permit(:started_on, :finished_on, :user_id).merge(book_id: params[:book_id])
  end
end
