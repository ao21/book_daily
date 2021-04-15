class BooksController < ApplicationController
  include GoogleBooksApi

  def search
    if params[:keyword]
      url = url_from_keyword(params[:keyword])
      @books = get_json_from_url(url)
    end
  end
end
