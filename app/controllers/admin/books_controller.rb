class Admin::BooksController < ApplicationController
  skip_before_action :verify_authenticity_token  # Required for Postman requests
  def index
    books = Book.includes(:authors).all

    render json: books.as_json(
      only: [:id, :title, :isbn, :description, :book_type, :genre],
      include: {
        authors: {
          only: [:id, :name]
        }
      }
    )
  end
  def new
end


  def upload_csv
  errors = []

  
  if params[:title].present?

  row = [
    params[:title],
    params[:isbn],
    params[:authors],
    params[:description],
    params[:book_type],
    params[:genre].presence || "Common"
  ].join(";") 
  rows = [row]
else
  csv_text = request.body.read
  rows = csv_text.strip.split("\n")
end


  rows.each_with_index do |line, index|
    cols = line.split(';').map(&:strip)
    next if cols.length < 5

    title, isbn, authors_str, description, type, genre = cols
    genre ||= "Common"

    if isbn.blank? || authors_str.blank?
      errors << "Row #{index + 1}: Missing ISBN or author"
      next
    end

    book = Book.find_or_initialize_by(isbn: isbn)
    book.title = title
    book.description = description
    book.book_type = type
    book.genre = genre
    book.save!

    authors = authors_str.split(',').map(&:strip)
    authors.each do |author_name|
      author = Author.find_or_create_by(name: author_name)
      BookAuthor.find_or_create_by(book: book, author: author)
    end
  rescue => e
    errors << "Row #{index + 1}: #{e.message}"
  end

  if params[:title].present?
    if errors.any?
      flash[:alert] = errors.join("<br>").html_safe
    else
      flash[:notice] = "Book/magazine added successfully."
    end
    redirect_to admin_books_new_path
  else
    if errors.any?
      render json: { status: "error", errors: errors }, status: :unprocessable_entity
    else
      render json: { status: "success", message: "Books uploaded successfully" }, status: :ok
    end
  end
end

end
