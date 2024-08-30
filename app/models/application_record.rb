class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  #Custom validation method for capacity range for tables and parties
  def self.validates_capacity_range(attr, min: 2, max: 8)
    validates attr, numericality: {
    only_integer: true, 
    greater_than_or_equal_to: min,
    less_than_or_equal_to: max
  }
  end
end
