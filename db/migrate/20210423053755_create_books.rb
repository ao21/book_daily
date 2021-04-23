class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books, id: false  do |t|
      t.bigint :isbn, null: false, primary_key: true
      t.string :title
      t.string :author
      t.string :image_link
      t.integer :page_count

      t.timestamps
    end
  end
end
