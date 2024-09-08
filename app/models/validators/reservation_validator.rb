module Validators
  module ReservationValidator
    def check_if_start_time_passed
      if start_time_was.present? && start_time_was <= Time.zone.now
        errors.add(:base, 'Cannot update reservation as the original start time has passed.')
        throw :abort
      end
    end
    
    def start_time_must_be_in_the_future
      if start_time.present? && start_time <= Time.zone.now
        errors.add(:start_time, 'must be in the future')
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
      if table.present? #Ensure reservations method is available to use
        existing_reservations = table.reservations.where(start_time: start_time)
        if existing_reservations.count > 0 && !existing_reservations.include?(self)
          errors.add(:start_time, 'has already been reserved')
        end
      end
    end
  end
end