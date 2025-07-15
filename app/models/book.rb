class Book < ApplicationRecord
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors

  validates :isbn, presence: true
  validates :title, presence: true
end
