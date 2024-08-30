class Reservation < ApplicationRecord
  belongs_to :table
  
  validates :name, presence: true
  validates :party_count, presence: true
  validates_capacity_range :party_count
  validates :start_time, presence: true
  validate :start_time_booking

  private

  def start_time_booking
    if start_time.present? && start_time < (DateTime.now + 1.hour)
      errors.add(:start_time, 'must be at least an hour after the current time')
    end
  end
end
