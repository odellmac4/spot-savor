class Reservation < ApplicationRecord
  include Validators::ReservationValidator

  validates :name, presence: true
  validates :party_count, presence: true
  validates :start_time, presence: true
  validates :table_id, presence: true
  validates_capacity_range :party_count
  
  #Custom validators
  validate :start_time_date
  validate :start_time_on_the_hour
  validate :table_eligibility
  validate :table_availability

  belongs_to :table

  
end
