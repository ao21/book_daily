module GoogleBooksApi
  def get_json_from_url(url)
    JSON.parse(Net::HTTP.get(URI.parse(Addressable::URI.encode(url))))
  end

  def url_from_keyword(keyword)
    "https://www.googleapis.com/books/v1/volumes?q=#{keyword}&country=JP&maxResults=20"
  end
end