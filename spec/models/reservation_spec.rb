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
  let(:invalid_reservation8) {build(:reservation, start_time: DateTime.new(7654, 87, 67, 10, 0, 0), table_id: table1.id)}

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

  describe '#self.descending' do
    it 'orders reservations in descending order' do
      expect(Reservation.descending).to eq([reservation2])
      reservation_3 = create(:reservation, table_id: table1.id)
      expect(Reservation.descending).to eq([reservation_3, reservation2])
      reservation_4 = create(:reservation, party_count: 4, table_id: table2.id)
      expect(Reservation.descending).to eq([reservation_4, reservation_3, reservation2])

      expect(Reservation.descending).to_not eq([reservation_3, reservation_4, reservation2])
      expect(Reservation.descending).to_not eq([reservation_3, reservation2, reservation_4])
      expect(Reservation.descending).to_not eq([reservation2, reservation_3, reservation_4])
      expect(Reservation.descending).to_not eq([reservation_4, reservation2, reservation_3])
    end
  end

  describe '#self.upcoming_reservations' do
    next_month = DateTime.now.month + 1
    
    let!(:resy_1) {create(:reservation, start_time: DateTime.new(2024, next_month, 1, 11, 0, 0), table_id: table1.id)}
    let!(:resy_2) {create(:reservation, start_time: DateTime.new(2024, next_month, 2, 13, 0, 0), table_id: table1.id)}
    let!(:resy_3) {create(:reservation, start_time: DateTime.new(2024, next_month, 3, 15, 0, 0), table_id: table1.id)}
    let!(:resy_4) {create(:reservation, start_time: DateTime.new(2024, next_month, 4, 9, 0, 0), table_id: table1.id)}
    let!(:resy_5) {create(:reservation, start_time: DateTime.new(2024, next_month, 5, 7, 0, 0), table_id: table1.id)}
    let!(:resy_6) {create(:reservation, start_time: DateTime.new(2024, (next_month + 1) , 10, 17, 0, 0), table_id: table1.id)}
    let!(:resy_7) {create(:reservation, start_time: DateTime.new(2024, (next_month + 2) , 12, 1, 0, 0), table_id: table1.id)}
    let!(:resy_8) {create(:reservation, start_time: DateTime.new(2024, (next_month + 2) , 14, 6, 0, 0), table_id: table1.id)}
    
    it 'returns top five upcoming reservations' do
      expect(Reservation.upcoming_reservations.count).to eq 5
      expect(Reservation.upcoming_reservations).to eq [resy_1, resy_2, resy_3, resy_4, resy_5]
      expect(Reservation.upcoming_reservations).to_not eq [resy_1, resy_2, resy_3, resy_4, resy_5, resy_6]
      added_resy = create(:reservation, start_time: DateTime.new(2024, next_month, 3, 7, 0, 0), table_id: table1.id)
      expect(Reservation.upcoming_reservations).to eq [resy_1, resy_2, added_resy, resy_3, resy_4]
    end
  end
end
