
require "csv"

class Admin::BooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def upload_csv
    csv_text = request.body.read
    delimiter = ";"
    errors = []
    success_count = 0

    ActiveRecord::Base.transaction do
      CSV.parse(csv_text, col_sep: delimiter).each_with_index do |row, index|
        next if row.compact.empty?

        book, author_str, row_errors = build_book_from_csv_row(row, index)

        if row_errors.any?
          errors.concat(row_errors)
          next
        end


        author_names = author_str.to_s.split(",").map(&:strip).reject(&:blank?)
        book.authors = author_names.map { |name| Author.find_or_create_by(name: name) }

        if book.save
          success_count += 1
        else
          errors << "Row #{index + 1}: #{book.errors.full_messages.join(', ')}"
        end
      end
    end

    if errors.any?
      render json: { success: success_count, errors: errors }, status: :unprocessable_entity
    else
      render json: { message: "#{success_count} records processed successfully." }, status: :ok
    end
  end

  private

  def build_book_from_csv_row(row, index)
   if row.size < 6
    return [ nil, nil, [ "Row #{index + 1}: Incomplete record (expected 6 fields)" ] ]
   end


   title, isbn, author_str, description, type_str, genre = row.map { |v| v&.strip }

   genre = "Common" if genre.blank?

   book = Book.find_or_initialize_by(isbn: isbn)
   book.assign_attributes(
    title: title,
    description: description,
    genre: genre,
    book_type: type_str.to_s.downcase
  )

   [ book, author_str, [] ]
  end
end
