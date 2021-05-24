class Task < ApplicationRecord
  belongs_to :book
  belongs_to :user
  has_many :reads
end