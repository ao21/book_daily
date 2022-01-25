module BooksHelper
  def book_image(image_link)
    if image_link.present?
      image_link
    else
      'book.png'
    end
  end
end