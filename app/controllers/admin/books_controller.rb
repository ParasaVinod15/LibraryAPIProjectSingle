class Admin::BooksController < ApplicationController
  skip_before_action :verify_authenticity_token  # Required for Postman requests
  def index
  @books = Book.includes(:authors).all

  if params[:isbn].present?
    @books = @books.where(isbn: params[:isbn])
  end

  if params[:book_type].present?
    @books = @books.where(book_type: params[:book_type])
  end

  if params[:genre].present?
    @books = @books.where("LOWER(genre) LIKE ?", "%#{params[:genre].downcase}%")
  end

  if params[:author].present?
    @books = @books.joins(:authors).where("LOWER(authors.name) LIKE ?", "%#{params[:author].downcase}%")
  end
  end


  def new
  end


  def upload_csv
    csv_text = request.body.read
    delimiter = ";"

    rows = csv_text.split("\n")
    errors = []
    success_count = 0

    ActiveRecord::Base.transaction do
      rows.each_with_index do |line, index|
        next if line.strip.blank?

        columns = line.strip.split(delimiter, -1)

        if columns.size < 6
          errors << "Row #{index + 1}: Incomplete record (expected 6 fields)"
          next
        end

        title, isbn, author_str, description, type_str, genre = columns.map(&:strip)
        genre = "Common" if genre.blank?

        # Validate fields
        missing_fields = []
        missing_fields << "title" if title.blank?
        missing_fields << "ISBN" if isbn.blank?
        missing_fields << "author" if author_str.blank?
        missing_fields << "description" if description.blank?
        missing_fields << "type" if type_str.blank?

        unless %w[book magazine].include?(type_str.to_s.downcase)
          missing_fields << "valid type (must be 'book' or 'magazine')"
        end

        if missing_fields.any?
          errors << "Row #{index + 1}: Missing or invalid #{missing_fields.join(', ')}"
          next
        end

        book_type = type_str.downcase == "book" ? :book : :magazine

        book = Book.find_or_initialize_by(isbn: isbn)
        book.assign_attributes(
          title: title,
          description: description,
          genre: genre,
          book_type: book_type
        )

        if book.save
          author_names = author_str.split(",").map(&:strip).reject(&:blank?)
          if author_names.empty?
            errors << "Row #{index + 1}: No valid authors provided"
            next
          end
          book.authors = author_names.map { |name| Author.find_or_create_by(name: name) }
          success_count += 1
        else
          errors << "Row #{index + 1}: #{book.errors.full_messages.join(', ')}"
        end
      end # end of rows.each
    end # end of transaction

    if errors.any?
      render json: { success: success_count, errors: errors }, status: :unprocessable_entity
    else
      render json: { message: "#{success_count} records processed successfully." }, status: :ok
    end
  end
end
