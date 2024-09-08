require 'rails_helper'

RSpec.describe Reservation, type: :model do
  let!(:table1) {create(:table, capacity: 8)}
  let!(:table2) {create(:table, capacity: 4)}
  let(:reservation1) {create(:reservation, table_id: table1.id)}
  let!(:reservation2) {create(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0),table_id: table1.id)}
  let(:reservation3) {create(:reservation, party_count: 4, start_time: current_time_top_hour + 2.days,table_id: table2.id)}
  

  #Invalid instances
  let(:current_time) {Time.zone.now}
  let(:current_time_top_hour) {Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)}
  let(:invalid_reservation1) {build(:reservation, party_count: 9,table_id: table1.id)}
  let(:invalid_reservation2) {build(:reservation, party_count: 1, table_id: table1.id)}
  let(:invalid_reservation3) {build(:reservation, start_time: DateTime.new(2024, 8, 24, 20, 0, 0), table_id: table1.id)}
  let(:invalid_reservation4) {build(:reservation, start_time: current_time_top_hour - 1.hour, table_id: table1.id)}
  let(:invalid_reservation5) {build(:reservation, start_time: DateTime.new(2030, 8, 24, 20, 30), table_id: table1.id)}
  let(:invalid_reservation6) {build(:reservation, party_count: 6, table_id: table2.id)}
  let(:invalid_reservation7) {build(:reservation, start_time: DateTime.new(2024, 12, 24, 20, 0, 0), table_id: table1.id)}
  let(:invalid_reservation8) {build(:reservation, party_count: 5, start_time: current_time_top_hour - 2.hour, table_id: table2.id)}
  let(:invalid_reservation9) {build(:reservation, party_count: 5, start_time: current_time_top_hour + 2.days, table_id: table2.id)}

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

    it 'is invalid if start time not in the future' do
      expect(invalid_reservation3).to be_invalid
      expect(invalid_reservation3.errors[:start_time]).to include('must be in the future')
      expect(invalid_reservation4).to be_invalid
      expect(invalid_reservation4.errors[:start_time]).to include('must be in the future')
    end

    it 'is invalid if start time is not at the top of the hour' do
      expect(invalid_reservation5).to be_invalid
      expect(invalid_reservation5.errors[:start_time]).to include('must start at the top of an hour')
    end

    it 'is invalid if the start time has already been reserved' do
      expect(invalid_reservation7).to be_invalid
      expect(invalid_reservation7.errors[:start_time]).to include('has already been reserved')
    end

    it 'throws multiple errors when creating a reservation' do
      expect(invalid_reservation8).to be_invalid
      expect(invalid_reservation8.errors[:start_time]).to include('must be in the future')
      expect(invalid_reservation8.errors[:party_count]).to include('is too big for the table capacity')

      reservation = reservation3
      expect(invalid_reservation9).to be_invalid
      expect(invalid_reservation9.errors[:start_time]).to include('has already been reserved')
      expect(invalid_reservation9.errors[:party_count]).to include('is too big for the table capacity')
    end

    describe 'validations when updating a reservation' do
      it 'is valid if attrs are updated to valid inputs' do
        reservation1.update(party_count: 4, table_id: table2.id, start_time: current_time_top_hour + 1.hour)
        expect(reservation1).to be_valid
      end

      it 'throws errors if attrs are updated to invalid inputs' do
        reservation1.update(party_count: 5, table_id: table2.id, start_time: current_time_top_hour + 1.hour)
        expect(reservation1.errors[:party_count]).to include('is too big for the table capacity')
        expect(reservation1.errors[:start_time]).to_not include('has already been reserved')
        expect(reservation1.errors[:start_time]).to_not include('must be in the future')
  
        reservation2.update(party_count: 7, table_id: table2.id, start_time: current_time_top_hour)
        expect(reservation2.errors[:start_time]).to include('must be in the future')
        expect(reservation2.errors[:party_count]).to include('is too big for the table capacity')
        expect(reservation1.errors[:start_time]).to_not include('has already been reserved')

        reservation1.update(party_count: 5, table_id: table1.id, start_time: DateTime.new(2024, 12, 24, 20, 0, 0))
        expect(reservation1.errors[:start_time]).to include('has already been reserved')
        expect(reservation1.errors[:party_count]).to_not include('is too big for the table capacity')
        expect(reservation1.errors[:start_time]).to_not include('must be in the future')

      end

      it 'cannot update a reservation where the start time has passed' do
        reservation1.update(party_count: 7, table_id: table1.id, start_time: current_time_top_hour + 1.hour)
        expect(reservation1).to be_valid

        travel_to current_time_top_hour + 2.hours do
          reservation1.update(party_count: 5, table_id: table1.id, start_time: current_time_top_hour + 5.hours)
          expect(reservation1.errors[:base]).to include('Cannot update reservation as the original start time has passed.')
        end
      end
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
    it 'returns top five upcoming reservations' do
      next_month = DateTime.now.month + 1
    
      resy_1 = create(:reservation, start_time: DateTime.new(2024, next_month, 1, 11, 0, 0), table_id: table1.id)
      resy_2 = create(:reservation, start_time: DateTime.new(2024, next_month, 2, 13, 0, 0), table_id: table1.id)
      resy_3 = create(:reservation, start_time: DateTime.new(2024, next_month, 3, 15, 0, 0), table_id: table1.id)
      resy_4 = create(:reservation, start_time: DateTime.new(2024, next_month, 4, 9, 0, 0), table_id: table1.id)
      resy_5 = create(:reservation, start_time: DateTime.new(2024, next_month, 5, 7, 0, 0), table_id: table1.id)
      resy_6 = create(:reservation, start_time: DateTime.new(2024, (next_month + 1) , 10, 17, 0, 0), table_id: table1.id)
      resy_7 = create(:reservation, start_time: DateTime.new(2024, (next_month + 2) , 12, 1, 0, 0), table_id: table1.id)
      resy_8 = create(:reservation, start_time: DateTime.new(2024, (next_month + 2) , 14, 6, 0, 0), table_id: table1.id)
      resy_9 = create(:reservation, start_time: current_time_top_hour + 2.hours, table_id: table1.id)
      expect(Reservation.upcoming_reservations.count).to eq 5
      expect(Reservation.upcoming_reservations).to eq [resy_9, resy_1, resy_2, resy_3, resy_4]
      expect(Reservation.upcoming_reservations).to_not eq [resy_1, resy_2, resy_3, resy_4, resy_9]
      added_resy = create(:reservation, start_time: DateTime.new(2024, next_month, 3, 7, 0, 0), table_id: table1.id)
      expect(Reservation.upcoming_reservations).to eq [resy_9, resy_1, resy_2, added_resy, resy_3]

      travel_to current_time_top_hour + 3.hours do
        expect(Reservation.upcoming_reservations).to eq [resy_1, resy_2, added_resy, resy_3, resy_4]
        expect(Reservation.upcoming_reservations).to_not eq [resy_9, resy_1, resy_2, added_resy, resy_3]
      end
    end
  end

  describe '#self.weekend_watchout' do
    it 'returns percentage of reservations booked on fri sat and sun' do
      resy_1 = create(:reservation, start_time: DateTime.new(2028, 12, 9, 11, 0, 0), table_id: table1.id)
      resy_2 = create(:reservation, start_time: DateTime.new(2028, 12, 9, 13, 0, 0), table_id: table1.id)
      resy_3 = create(:reservation, start_time: DateTime.new(2028, 12, 9, 15, 0, 0), table_id: table1.id)
      resy_4 = create(:reservation, start_time: DateTime.new(2028, 11, 11, 9, 0, 0), table_id: table1.id)
      resy_5 = create(:reservation, start_time: DateTime.new(2028, 11, 11, 7, 0, 0), table_id: table1.id)
      resy_6 = create(:reservation, start_time: DateTime.new(2028, 10 , 18, 17, 0, 0), table_id: table1.id)
      resy_7 = create(:reservation, start_time: DateTime.new(2028, 10 , 18, 1, 0, 0), table_id: table1.id)
      resy_8 = create(:reservation, start_time: DateTime.new(2028, 10 , 17, 6, 0, 0), table_id: table1.id)

      expect(Reservation.weekend_watchout).to be_a Float
      expect(Reservation.weekend_watchout).to eq 55.56

      resy_9 = create(:reservation, start_time: DateTime.new(2028, 10 , 17, 1, 0, 0), table_id: table1.id)
      resy_10 = create(:reservation, start_time: DateTime.new(2028, 10 , 17, 2, 0, 0), table_id: table1.id)
      resy_11 = create(:reservation, start_time: DateTime.new(2028, 8 , 4, 12, 0, 0), table_id: table1.id)
      resy_12 = create(:reservation, start_time: DateTime.new(2028, 8 , 5, 5, 0, 0), table_id: table1.id)
      resy_13 = create(:reservation, start_time: DateTime.new(2028, 8 , 1, 6, 0, 0), table_id: table1.id)

      expect(Reservation.weekend_watchout).to eq 50.0
    end
  end

  describe '#self.reservation_rush' do
    it 'returns top 2 most popular times of reservation bookings' do
      resy_1 = create(:reservation, start_time: Time.zone.local(2028, 12, 9, 11, 0, 0), table_id: table1.id)
      resy_2 = create(:reservation, start_time: Time.zone.local(2028, 12, 10, 11, 0, 0), table_id: table1.id)
      resy_3 = create(:reservation, start_time: Time.zone.local(2028, 12, 11, 11, 0, 0), table_id: table1.id)
      resy_4 = create(:reservation, start_time: Time.zone.local(2028, 11, 11, 9, 0, 0), table_id: table1.id)
      resy_5 = create(:reservation, start_time: Time.zone.local(2028, 11, 12, 9, 0, 0), table_id: table1.id)
      resy_6 = create(:reservation, start_time: Time.zone.local(2028, 10 , 18, 12, 0, 0), table_id: table1.id)
      resy_7 = create(:reservation, start_time: Time.zone.local(2028, 10 , 17, 18, 0, 0), table_id: table1.id)
      resy_8 = create(:reservation, start_time: Time.zone.local(2028, 10 , 16, 5, 0, 0), table_id: table1.id)

      expect(Reservation.reservation_rush).to eq ["11:00 AM", "09:00 AM"]
    end
  end
end
