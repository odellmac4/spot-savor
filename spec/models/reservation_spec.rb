require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let!(:table1) {create(:table)}
  let!(:reservation1) {create(:reservation, table_id: table1.id)}

  #Invalid instances
  let!(:invalid_reservation1) {build(:reservation, party_count: 9, table_id: table1.id)}
  let!(:invalid_reservation2) {build(:reservation, party_count: 1, table_id: table1.id)}
  let!(:invalid_reservation3) {build(:reservation, start_time: DateTime.now - 30.minutes, table_id: table1.id)}
  let!(:invalid_reservation4) {build(:reservation, start_time: DateTime.yesterday, table_id: table1.id)}

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:party_count)}
    it {should validate_presence_of(:start_time)}
    it {should belong_to(:table)}

    it 'is valid if party count is in required range of 2 to 8' do
      expect(reservation1).to be_valid
    end

    it 'is invalid if party count is outside of required range of 2 to 8' do
      expect(invalid_reservation1).to be_invalid
      expect(invalid_reservation1.errors[:party_count]).to include('must be less than or equal to 8')
      expect(invalid_reservation2).to be_invalid
      expect(invalid_reservation2.errors[:party_count]).to include('must be greater than or equal to 2')
    end

    it 'is invalid if datetime is less than an hour from current time' do
      expect(invalid_reservation3).to be_invalid
      expect(invalid_reservation3.errors[:start_time]).to include('must be at least an hour after the current time')
      expect(invalid_reservation4).to be_invalid
      expect(invalid_reservation4.errors[:start_time]).to include('must be at least an hour after the current time')
    end
  end
end
