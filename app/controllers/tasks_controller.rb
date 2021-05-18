class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
    @tasks = current_user.tasks.order(id: :asc)
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @book = Book.find_by(id: params[:book_id])
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      redirect_to tasks_path, notice: "目標を登録しました"
    else
      render :new, alert: "目標の登録に失敗しました"
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    task = Task.find(params[:id])
    task.update!(task_params)
    redirect_to task, notice: "更新しました"
  end

  def destroy
    task = Task.find(params[:id])
    task.destroy!
    redirect_to tasks_path, alert: "削除しました"
  end

  private

  def task_params
    params.require(:task).permit(:started_on, :finished_on, :user_id).merge(book_id: params[:book_id])
  end
end
