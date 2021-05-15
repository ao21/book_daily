class BooksController < ApplicationController
  include GoogleBooksApi

  def search
    if params[:keyword]
      url= url_from_keyword(params[:keyword])
      results = get_json_from_url(url)
      @results_data = Book.results_data(results)
    end
  end

  def new
    @book = Book.find_or_initialize_by(title: params[:title])

    unless @book.persisted?
      @book = Book.new(book_data)
    end
  end

  def create
    book = Book.create(book_params)

    if book.save
      redirect_to new_task_path(book_id: @book.id), notice: "本を登録しました"
    else
      render :new, alert: "本の登録に失敗しました"
    end
  end

  private

  def book_data
    {
      title: params[:title],
      author: params[:author],
      image_link: params[:image_link],
      page_count: params[:page_count],
    }
  end

  def book_params
    params.permit(:title, :author, :image_link, :page_count)
  end
end