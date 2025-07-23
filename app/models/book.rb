
class Book < ApplicationRecord
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors

  validates :isbn, :title, :description, :genre, :book_type, presence: true
  validates :book_type, inclusion: { in: %w[book magazine], message: "must be 'book' or 'magazine'" }
  validate :must_have_at_least_one_author

  scope :by_isbn, ->(isbn) { where(isbn: isbn) }
  scope :by_author, ->(author) { joins(:authors).where("LOWER(authors.name) LIKE ?", "%#{author.downcase}%") }
  scope :by_title, ->(title) { where("LOWER(title) LIKE ?", "%#{title.downcase}%") }
  scope :sorted, -> { order(:book_type, :title) }
  private

  def must_have_at_least_one_author
    if authors.blank? || authors.reject(&:marked_for_destruction?).empty?
      errors.add(:authors, "must be present")
    end
  end
end
