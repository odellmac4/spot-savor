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

  def self.descending
    self.order(created_at: :desc)
  end

  def self.upcoming_reservations
    self.order(start_time: :asc).limit(5)
  end

  def self.weekend_watchout
    weekend_reservations = self.where("EXTRACT(DOW FROM start_time) IN (5, 6, 0)")
    weekend_reservations_percentage = ((weekend_reservations.count.to_f / self.all.count) * 100).round(2)
  end

  def self.reservation_rush
    reservation_times_with_count = self.group("EXTRACT(HOUR FROM start_time AT TIME ZONE 'UTC')").count
    top_times = reservation_times_with_count.max_by(2) { |key, value| value }.to_h
    formatted_times = []
    
    top_times.each do |hour, _|
      utc_time = Time.utc(2000, 1, 1, hour.to_i)
      local_time = utc_time.in_time_zone(Time.zone)
      formatted_hour = local_time.strftime("%I:%M %p")
      formatted_times << formatted_hour
    end
    formatted_times
  end
end
