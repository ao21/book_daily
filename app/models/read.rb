class Read < ApplicationRecord
  belongs_to :task

  with_options presence: true do
    validates :read_on
    validates :read_page, numericality: { only_integer: true }
  end
end
