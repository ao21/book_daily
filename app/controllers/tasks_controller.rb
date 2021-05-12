class TasksController < ApplicationController
  def index
  end

  def show
  end

  def new
    book_id = params[:book_id]
    @book = Book.find_by(id: book_id)
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
