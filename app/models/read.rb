class Read < ApplicationRecord
  belongs_to :task
  has_one :user, through: :task

  with_options presence: true do
    validates :read_on
    validates :read_page, numericality: { only_integer: true }
  end

  def start_time
    self.read_on
  end
end
