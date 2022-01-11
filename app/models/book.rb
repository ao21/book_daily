class Book < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :total_pages, presence: true, numericality: true

  # GoogleBooksAPIでの検索結果を配列に整形
  def self.results_data(results)
    results_data = []

    results["items"].each do |result|
      title = result.dig("volumeInfo", "title")
      authors = result.dig("volumeInfo", "authors")
      image_link = result.dig("volumeInfo", "imageLinks", "smallThumbnail")
      total_pages = result.dig("volumeInfo", "pageCount")

      # 総ページ数のデータがない場合は検索結果に表示しない
      if total_pages.blank?
        next
      end

      # 著者が複数名の場合の表記
      if authors
        author = authors.join(', ')
      end

      results_data.push(
        {
          title: title,
          author: author,
          image_link: image_link,
          total_pages: total_pages
        }
      )
    end
    return results_data
  end
end
