class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :isbn
      t.text :description
      t.string :book_type
      t.string :genre

      t.timestamps
    end
  end
end
