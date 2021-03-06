class Book < ApplicationRecord
  has_many :tasks, dependent: :destroy

  # バリデーション
  validates :title, presence: true
  validates :total_pages, presence: true, numericality: true
  validates :google_id, presence: true, uniqueness: true

  # GoogleBooksAPIでの検索結果を配列に整形
  def self.results_array(results_json)
    results = []

    results_json["items"].each do |result|
      google_id = result.dig("id")
      info = result.dig("volumeInfo")
      title = info.dig("title")
      authors = info.dig("authors")
      image_link = info.dig("imageLinks", "smallThumbnail")
      total_pages = info.dig("pageCount")

      # 総ページ数のデータがない書籍は検索結果に表示しない
      if total_pages.blank?
        next
      end

      # 著者が複数名の表記
      if authors
        author = authors.join(', ')
      end

      results.push(
        {
          google_id: google_id,
          title: title,
          author: author,
          image_link: image_link,
          total_pages: total_pages
        }
      )
    end
    return results
  end
end
