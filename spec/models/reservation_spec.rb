require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let!(:table1) {create(:table, capacity: 8)}
  let!(:table2) {create(:table, capacity: 4)}
  let(:reservation1) {create(:reservation, table_id: table1.id)}
  let!(:reservation2) {create(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0),table_id: table1.id)}

  #Invalid instances
  let(:invalid_reservation1) {build(:reservation, party_count: 9,table_id: table1.id)}
  let(:invalid_reservation2) {build(:reservation, party_count: 1, table_id: table1.id)}
  let(:invalid_reservation3) {build(:reservation, start_time: DateTime.new(2024, 8, 24, 20, 0, 0), table_id: table1.id)}
  let(:invalid_reservation4) {build(:reservation, start_time: DateTime.yesterday, table_id: table1.id)}
  let(:invalid_reservation5) {build(:reservation, start_time: DateTime.new(2030, 8, 24, 20, 30), table_id: table1.id)}
  let(:invalid_reservation6) {build(:reservation, party_count: 6, table_id: table2.id)}
  let(:invalid_reservation7) {build(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0), table_id: table1.id)}

  describe 'validations' do
    it {should validate_presence_of(:name)}
    it {should validate_presence_of(:party_count)}
    it {should validate_presence_of(:start_time)}
    it {should validate_presence_of(:table_id)}
    it {should validate_numericality_of(:party_count)}
    it {should belong_to(:table)}

    it 'is valid if party count is in required range of 2 to 8' do
      expect(reservation1).to be_a Reservation
    end

    it 'is invalid if party count is outside of required range of 2 to 8' do
      expect(invalid_reservation1).to be_invalid
      expect(invalid_reservation1.errors[:party_count]).to include('must be less than or equal to 8')
      
      expect(invalid_reservation2).to be_invalid
      expect(invalid_reservation2.errors[:party_count]).to include('must be greater than or equal to 2')
    end

    it 'is invalid if party count is greater than the table capacity' do
      expect(invalid_reservation6).to be_invalid
      expect(invalid_reservation6.errors[:party_count]).to include('is too big for the table capacity')
    end

    it 'is invalid if start time` is less than an hour from current time' do
      expect(invalid_reservation3).to be_invalid
      expect(invalid_reservation3.errors[:start_time]).to include('must be at least an hour after the current time')
      expect(invalid_reservation4).to be_invalid
      expect(invalid_reservation4.errors[:start_time]).to include('must be at least an hour after the current time')
    end

    it 'is invalid if start time is not at the top of the hour' do
      expect(invalid_reservation5).to be_invalid
      expect(invalid_reservation5.errors[:start_time]).to include('must start at the top of an hour')
    end

    it 'is invalid if the start time has already been reserved' do
      expect(invalid_reservation7).to be_invalid
      expect(invalid_reservation7.errors[:start_time]).to include('has already been reserved')
    end
  end
end
