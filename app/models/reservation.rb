class Reservation < ApplicationRecord
  belongs_to :table
  
  validates :name, presence: true
  validates :party_count, presence: true
  validates :start_time, presence: true
  validates :table_id, presence: true
  validates_capacity_range :party_count
  validate :start_time_date
  validate :start_time_on_the_hour
  validate :table_eligibility
  validate :table_availability

  private

  def start_time_date
    if start_time.present? && start_time <= (DateTime.now + 1.hour)
      errors.add(:start_time, 'must be at least an hour after the current time')
    end
  end

  def start_time_on_the_hour
    if start_time.present? && !start_time.min.zero?
      errors.add(:start_time, 'must start at the top of an hour')
    end
  end

  def table_eligibility
    if table.present? && party_count > table.capacity
      errors.add(:party_count, 'is too big for the table capacity')
    end
  end

  def table_availability
    if table.present?
      existing_reservations = table.reservations.where(start_time: start_time).count
      if existing_reservations > 0
        errors.add(:start_time, 'has already been reserved')
      end
    end
  end
end
