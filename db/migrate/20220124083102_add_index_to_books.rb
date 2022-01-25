class AddIndexToBooks < ActiveRecord::Migration[6.1]
  def change
    add_index :books, :google_id, unique: true
  end
end
