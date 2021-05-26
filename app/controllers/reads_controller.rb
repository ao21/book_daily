class ReadsController < ApplicationController
  def index
  end

  def show
  end

  def new
    @task = Task.find(params[:task_id])
    @read = Read.new
  end

  def create
    task = Task.find_by(id: params[:task_id])
    read = task.reads.build(read_params)

    if read.save
      redirect_to task_path(task.id)
    else
      render "tasks/show"
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def read_params
    params.require(:read).permit(:read_on, :read_page)
  end
end
