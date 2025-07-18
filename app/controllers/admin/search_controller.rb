class Admin::SearchController < ApplicationController
  def index
    books = Book.includes(:authors)

    if params[:isbn].present?
      books = books.where(isbn: params[:isbn])
    end

    if params[:author].present?
      books = books.joins(:authors).where("LOWER(authors.name) LIKE ?", "%#{params[:author].downcase}%")
    end

    if params[:title].present?
      books = books.where("LOWER(title) LIKE ?", "%#{params[:title].downcase}%")
    end

    books = books.order(:book_type, :title)

    render json: books.as_json(
      include: { authors: { only: :name } },
      except: [ :created_at, :updated_at ]
    )
  end
end
