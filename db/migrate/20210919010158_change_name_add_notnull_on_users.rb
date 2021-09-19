class ChangeNameAddNotnullOnUsers < ActiveRecord::Migration[6.1]
  def change
    change_column :users, :name, :string, default: "", null: false
  end
end
