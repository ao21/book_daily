class Book < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :page_count, presence: true, numericality: true

  # GoogleBooksAPIでの検索結果を配列に整形
  def self.results_data(results)
    results_data = []

    results["items"].each do |result|
      title = result.dig("volumeInfo", "title")
      authors = result.dig("volumeInfo", "authors")
      image_link = result.dig("volumeInfo", "imageLinks", "smallThumbnail")
      page_count = result.dig("volumeInfo", "pageCount")

      # ページ数のデータがない場合は検索結果に表示しない
      if page_count.blank?
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
          page_count: page_count
        }
      )
    end
    return results_data
  end
end
