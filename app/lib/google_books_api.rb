module GoogleBooksApi

  # 定数
  MAX_RESULTS = 20

  # キーワード検索
  def url_from_keyword(keyword)
    "https://www.googleapis.com/books/v1/volumes?q=#{keyword}&country=JP&maxResults=#{MAX_RESULTS}"
  end

  # 検索結果のJSONを取得
  def get_json_from_url(url)
    JSON.parse(Net::HTTP.get(URI.parse(Addressable::URI.encode(url))))
  end
end