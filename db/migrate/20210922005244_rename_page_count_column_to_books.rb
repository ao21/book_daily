class RenamePageCountColumnToBooks < ActiveRecord::Migration[6.1]
  def change
    rename_column :books, :page_count, :total_pages
  end
end
