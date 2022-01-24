class AddGoogleIdToBooks < ActiveRecord::Migration[6.1]
  def change
    add_column :books, :google_id, :string, null: false, unique: true
  end
end
