class Table < ApplicationRecord
  validates :capacity, presence: true
  validates_capacity_range :capacity

  has_many :reservations, dependent: :destroy
end
