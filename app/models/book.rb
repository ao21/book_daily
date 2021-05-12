class Book < ApplicationRecord

  validates :title, presence: true
  validates :image_link, format: /\A#{URI::regexp(%w(http https))}\z/
  validates :page_count, presence: true, numericality: true

  # GoogleBooksAPIでの検索結果を配列に整形
  def self.results_data(results)

    results_data = []

    results["items"].each do |result|
      title = result.dig("volumeInfo", "title")
      authors = result.dig("volumeInfo", "authors")
      image_link = result.dig("volumeInfo", "imageLinks", "smallThumbnail")
      page_count = result.dig("volumeInfo", "pageCount")

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
