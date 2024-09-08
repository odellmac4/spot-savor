require 'rails_helper'

RSpec.describe 'Create reservation' do
  describe 'form to initiate creation of a reservation' do
    let!(:table_1) {create(:table, capacity: 8)}
    let!(:table_2) {create(:table, capacity: 6)}
    let!(:table_3) {create(:table, capacity: 5)}
    let!(:table_4) {create(:table, capacity: 3)}
    let(:current_time) {Time.zone.now}
    let(:current_time_top_hour) {Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)}

    before do
      visit new_reservation_path
    end
  
    it 'has required fields to create a reservation' do
      within ".reservation-form" do
        expect(page).to have_field("reservation-name")
        expect(page).to have_select("reservation-year", with_options: [
          2024, 2025, 2026, 2027, 2028, 2029
        ])
        expect(page).to have_select("reservation-month", with_options:
          [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
          ]
        )
        expect(page).to have_select("reservation-day", with_options: (1..31))
        expect(page).to have_select("reservation-time", with_options: [
          "12:00",
          "1:00",
          "2:00",
          "3:00",
          "4:00",
          "5:00",
          "6:00",
          "7:00",
          "8:00",
          "9:00",
          "10:00",
          "11:00"
        ])
        expect(page).to have_select("am-pm", with_options: ["AM", "PM"])
        expect(page).to have_select("reservation-party", with_options: (2..8))
        expect(page).to have_select("reservation-table", with_options: [
          "Table #{table_1.id} - Capacity: 8",
          "Table #{table_2.id} - Capacity: 6",
          "Table #{table_3.id} - Capacity: 5",
          "Table #{table_4.id} - Capacity: 3"
                ])
        expect(page).to have_button("Create Reservation")
        expect(page).to have_link("Cancel", href: reservations_path)
      end
    end
  
    it 'fills in form with all valid information to create a reservation and leads to reservations index' do  
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "3", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")
      end

      expect(current_path).to eq reservations_path
      expect(page).to have_content "Reservation was successfully created."

      reservation = Reservation.last
      expect(reservation.name).to eq "Slayana"
      expect(reservation.party_count).to eq 3
      expect(reservation.start_time).to eq "Sun, 12 Jan 2025 19:00:00.000000000 CST -06:00"

      visit reservations_path  
      within "#reservation-#{reservation.id}" do
        expect(page).to have_content "Slayana"
        expect(page).to have_content "Party Count: 3"
        expect(page).to have_content "Reservation Date: Sun, Jan 12 2025"
        expect(page).to have_content "Reservation Time: 07:00 PM"
        expect(page).to have_content "Table #{table_4.id}"
      end
    end

    it 'validates that name must be more than 3 characters long.' do
      within ".reservation-form" do
        fill_in "reservation-name", with: "Sl"
        select "3", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")
        expect(page).to have_content "is too short (minimum is 3 characters)"
      end
    end
  
    it 'throws an error if party count exceeds table capacity' do
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "7", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
      end
    end

    it 'throws an error if start time is not in the future' do
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "7", from: "reservation-party"
        select "2024", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_1.id} - Capacity: 8", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Start time must be in the future"
      end
    end

    it 'throws an error if start time has been taken for selected table' do

      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "3", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")
      end
      expect(current_path).to eq reservations_path
      expect(page).to have_content "Reservation was successfully created."

      visit new_reservation_path

      within ".reservation-form" do
        fill_in "reservation-name", with: "Happy"
        select "2", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Start time has already been reserved"
      end

      visit reservations_path

      within ".reservations" do
        expect(page).to_not have_content "Happy"
        expect(page).to have_content "Slayana"
      end
    end

    it 'throws multiple errors if start time has been taken for selected table and party count exceeds table capacity' do
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "3", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "February", from: "reservation-month"
        select "14", from: "reservation-day"
        select "06:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")
      end
      expect(current_path).to eq reservations_path
      expect(page).to have_content "Reservation was successfully created."

      visit new_reservation_path

      within ".reservation-form" do
        fill_in "reservation-name", with: "Happy"
        select "4", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "February", from: "reservation-month"
        select "14", from: "reservation-day"
        select "06:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Start time has already been reserved"
        expect(page).to have_content "Party count is too big for the table capacity"
      end

      visit reservations_path

      within ".reservations" do
        expect(page).to_not have_content "Happy"
        expect(page).to have_content "Slayana"
      end
    end

    it 'throws multiple errors if start time is not in the future and party count exceeds table capacity' do
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "7", from: "reservation-party"
        select "2024", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Start time must be in the future"
        expect(page).to have_content "Party count is too big for the table capacity"
      end
    end

    it 'throws multiple errors if start time is not in the future and reservation has already been reserved' do
      start_time = current_time_top_hour + 1.hour
      reservation = create(:reservation, party_count: 3, start_time: start_time ,table_id: table_3.id)
      
      travel_to start_time + 5.hours do
        within ".reservation-form" do
          fill_in "reservation-name", with: "Slayana"
          select "7", from: "reservation-party"
          select start_time.year, from: "reservation-year"
          select start_time.strftime("%B"), from: "reservation-month"
          select start_time.day, from: "reservation-day"
          select "#{start_time.strftime("%I")}:00", from: "reservation-time"
          select start_time.strftime("%p"), from: "am-pm"
          select "Table #{table_3.id} - Capacity: 5", from: "reservation-table"
    
          click_button("Create Reservation")
  
          expect(page).to have_content "Start time must be in the future"
          expect(page).to have_content "Start time has already been reserved"
          expect(page).to have_content "Party count is too big for the table capacity"
        end
      end
    end

    it 'maintains user input if reservation is not created' do
      visit new_reservation_path
      
      within ".reservation-form" do
        fill_in "reservation-name", with: "Slayana"
        select "7", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_4.id} - Capacity: 3", from: "reservation-table"
  
        click_button("Create Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"

        expect(page).to have_field("reservation-name", with: "Slayana")
        expect(page).to have_select("reservation-party", selected: "7")
        expect(page).to have_select("reservation-month", selected: "January")
        expect(page).to have_select("reservation-day", selected: "12")
        expect(page).to have_select("reservation-time", selected: "07:00")
        expect(page).to have_select("am-pm", selected: "PM")
        expect(page).to have_select("reservation-table", selected: "Table #{table_4.id} - Capacity: 3")
      end
    end
  end
end