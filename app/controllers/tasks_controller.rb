class TasksController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def show
  end

  def new
    @book = Book.find_by(id: params[:book_id])
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)

    if @task.save
      flash[:success] = "目標を登録しました"
      redirect_to root_path
    else
      flash[:danger] = "目標の登録に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def task_params
    params.require(:task).permit(:started_on, :finished_on, :user_id).merge(book_id: params[:book_id])
  end
end
