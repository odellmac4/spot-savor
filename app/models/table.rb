class Table < ApplicationRecord
  has_many :reservations, dependent: :destroy

  validates :capacity, presence: true
  validates_capacity_range :capacity
end
