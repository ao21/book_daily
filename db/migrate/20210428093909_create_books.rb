class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string  :title,      null: false
      t.string  :author
      t.string  :image_link
      t.integer :page_count, null: false

      t.timestamps
    end
  end
end
