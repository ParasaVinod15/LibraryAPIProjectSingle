

class Admin::SearchController < ApplicationController
  def index
    books = Book.includes(:authors)
    books = books.by_isbn(params[:isbn]) if params[:isbn].present?
    books = books.by_author(params[:author]) if params[:author].present?
    books = books.by_title(params[:title]) if params[:title].present?
    books = books.sorted

    render json: books.as_json(
      include: { authors: { only: :name } },
      except: [ :created_at, :updated_at ]
    )
  end
end
