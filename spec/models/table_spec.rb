require 'rails_helper'

RSpec.describe Table, type: :model do
  let(:table1) {create(:table)}

  #Invalid instances
  let(:invalid_table1) {build(:table, capacity: 1)}
  let(:invalid_table2) {build(:table, capacity: 10)}

  describe 'validations' do
    it {should validate_presence_of(:capacity)}
    it {should validate_numericality_of(:capacity)}
    it {should have_many(:reservations)}

    it 'is valid if capacity is between 2 and 8' do
      expect(table1).to be_a Table
    end

    it 'is invalid if table capacity is not between 2 and 8' do
      expect(invalid_table1).to be_invalid
      expect(invalid_table1.errors[:capacity]).to include('must be greater than or equal to 2')

      expect(invalid_table2).to be_invalid
      expect(invalid_table2.errors[:capacity]).to include('must be less than or equal to 8')
    end
  end
end
