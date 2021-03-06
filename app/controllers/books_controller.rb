class BooksController < ApplicationController
  include GoogleBooksApi
  before_action :authenticate_user!, except: [:search, :new]

  def search
    if params[:keyword].present?
      url= url_from_keyword(params[:keyword])
      results_json = get_json_from_url(url)
      @results = Book.results_array(results_json)
    end
  end

  def new
    @book = Book.find_or_initialize_by(google_id: params[:google_id])

    unless @book.persisted?
      @book = Book.new(book_data)
    end
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to new_task_path(book_id: @book.id)
    else
      flash[:alert] = "本の登録に失敗しました"
      render :new
    end
  end

  private

  def book_data
    {
      google_id: params[:google_id],
      title: params[:title],
      author: params[:author],
      image_link: params[:image_link],
      total_pages: params[:total_pages],
    }
  end

  def book_params
    params.require(:book).permit(:google_id, :title, :author, :image_link, :total_pages)
  end
end