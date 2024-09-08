require 'rails_helper'

RSpec.describe 'Reservation update' do
  let(:current_time) {Time.zone.now}
  let(:current_time_top_hour) {Time.zone.local(current_time.year, current_time.month, current_time.day, current_time.hour)}
  let!(:table_1) {create(:table, capacity: 8)}
  let!(:table_2) {create(:table, capacity: 6)}
  let(:reservation_1) {create(:reservation, name: "Reyonce", start_time: Time.zone.local(2024, 12, 24, 10, 0, 0), party_count: 7, table_id: table_1.id)}
  let(:reservation_2) {create(:reservation, name: "Riot Johnson", start_time: Time.zone.local(2024, 11, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)}
  let(:reservation_3) {create(:reservation, name: "Miley", party_count: 5, start_time: current_time_top_hour + 2.hours, table_id: table_2.id)}

  describe 'form to edit an existing reservation' do
    it 'form fields are pre-filled with reservation data' do
      visit edit_reservation_path(reservation_3.id)

      
      within ".edit-reservation-form" do
        expect(page).to have_field("reservation-name", with: "Miley")
        expect(page).to have_select("reservation-party", selected: "5")
        expect(page).to have_select("reservation-month", selected: reservation_3.start_time.strftime("%B"))
        expect(page).to have_select("reservation-day", selected: "#{reservation_3.start_time.day}")
        expect(page).to have_select("reservation-time", selected: "#{reservation_3.start_time.strftime("%I")}:00")
        expect(page).to have_select("am-pm", selected: "#{reservation_3.start_time.strftime("%p")}")
        expect(page).to have_select("reservation-table", selected: "Table #{table_2.id} - Capacity: 6")
        expect(page).to have_button("Update Reservation")
        expect(page).to have_link("Cancel", href: reservation_path(reservation_3.id))
      end
    end

    it 'successfully updates a reservation and leads to reservation show page with successful alert' do
      visit edit_reservation_path(reservation_2.id)

      within ".edit-reservation-form" do
        fill_in "reservation-name", with: "Happy"
        select "6", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "January", from: "reservation-month"
        select "12", from: "reservation-day"
        select "08:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_1.id} - Capacity: 8", from: "reservation-table"

        click_button("Update Reservation")
      end

      expect(current_path).to eq reservation_path(reservation_2.id)
      expect(page).to have_content("Happy's reservation was updated successfully")
      
      visit reservation_path(reservation_2.id)

      within ".reservation-show-details" do
        expect(page).to have_content("Party Count: 6")
        expect(page).to have_content("Reservation Date: Sun, Jan 12 2025")
        expect(page).to have_content("Reservation Time: 08:00 PM")
        expect(page).to have_content("Table #{table_1.id}")
        expect(page).to have_content("Happy")

        expect(page).to_not have_content("Party Count: 5")
        expect(page).to_not have_content("Reservation Date: Sun, Nov 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
        expect(page).to_not have_content("Reyonce")
      end

      visit reservations_path

      within "#reservation-#{reservation_2.id}" do
        expect(page).to have_content("Party Count: 6")
        expect(page).to have_content("Reservation Date: Sun, Jan 12 2025")
        expect(page).to have_content("Reservation Time: 08:00 PM")
        expect(page).to have_content("Table #{table_1.id}")
        expect(page).to have_content("Happy")

        expect(page).to_not have_content("Party Count: 5")
        expect(page).to_not have_content("Reservation Date: Sun, Nov 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
        expect(page).to_not have_content("Reyonce")
      end
    end

    it 'throws an error when trying to update reservation table where capacity is smaller than party count' do
      visit edit_reservation_path(reservation_2.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        click_button("Update Reservation")
        expect(page).to have_content "Party count is too big for the table capacity"
      end

      visit reservations_path

      within "#reservation-#{reservation_2.id}" do
        expect(page).to have_content("Party Count: 5")
        expect(page).to_not have_content("Party Count: 7")
      end
    end

    it 'throws an error when trying to update reservation start time to a time that is not in the future' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "July", from: "reservation-month"
        click_button("Update Reservation")
        expect(page).to have_content "Start time must be in the future"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to_not have_content("Reservation Date: Wed, Jul 10 2024")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to_not have_content("Reservation Date: Wed, Jul 10 2024")
      end
    end

    it 'throws an error when trying to update reservation to an existing reservation for the chosen table' do
      reservation = create(:reservation, start_time: Time.zone.local(2025, 10, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)

      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "6", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "October", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Start time has already been reserved"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end

    it 'throws multiple errors if party count too big and start time is in the past' do
      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        select "2024", from: "reservation-year"
        select "March", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
        expect(page).to have_content "Start time must be in the future"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end

    it 'throws multiple errors if party count too big and start time has already been reserved' do
      reservation = create(:reservation, start_time: Time.zone.local(2025, 10, 10, 19, 0, 0), party_count: 5, table_id: table_2.id)

      visit edit_reservation_path(reservation_1.id)

      within ".edit-reservation-form" do
        select "7", from: "reservation-party"
        select "2025", from: "reservation-year"
        select "October", from: "reservation-month"
        select "10", from: "reservation-day"
        select "07:00", from: "reservation-time"
        select "PM", from: "am-pm"
        select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
  
        click_button("Update Reservation")

        expect(page).to have_content "Party count is too big for the table capacity"
        expect(page).to have_content "Start time has already been reserved"
      end

      visit reservation_path(reservation_1.id)

      within ".reservation-show-details" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end

      visit reservations_path

      within "#reservation-#{reservation_1.id}" do
        expect(page).to have_content('Reyonce')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table_1.id}")

        expect(page).to_not have_content("Party Count: 6")
        expect(page).to_not have_content("Reservation Date: Thu, Oct 10 2024")
        expect(page).to_not have_content("Reservation Time: 07:00 PM")
        expect(page).to_not have_content("Table #{table_2.id}")
      end
    end

    it "allows edit if start time is less than current time" do
      reservation = create(:reservation, party_count: 5, start_time: current_time_top_hour + 1.hour, table_id: table_2.id)

      visit edit_reservation_path(reservation.id)

      within ".edit-reservation-form" do
        expect(page).to have_field("reservation-name", with: reservation.name)
        expect(page).to have_select("reservation-party", selected: "5")
        expect(page).to have_select("reservation-month", selected: reservation.start_time.strftime("%B"))
        expect(page).to have_select("reservation-day", selected: "#{reservation.start_time.day}")
        expect(page).to have_select("reservation-time", selected: "#{reservation.start_time.strftime("%I")}:00")
        expect(page).to have_select("am-pm", selected: "#{reservation.start_time.strftime("%p")}")
        expect(page).to have_select("reservation-table", selected: "Table #{table_2.id} - Capacity: 6")

        travel_to reservation.start_time - 1.minute do
          fill_in "reservation-name", with: "Happy"
          select "6", from: "reservation-party"
          select "2025", from: "reservation-year"
          select "January", from: "reservation-month"
          select "12", from: "reservation-day"
          select "08:00", from: "reservation-time"
          select "PM", from: "am-pm"
          select "Table #{table_1.id} - Capacity: 8", from: "reservation-table"
          click_button("Update Reservation")
          expect(current_path).to eq reservation_path(reservation.id)
        end
      end
      
      visit reservation_path(reservation.id)
      within ".reservation-show-details" do
        expect(page).to have_content "Happy"
        expect(page).to have_content "Party Count: 6"
        expect(page).to have_content "Reservation Date: Sun, Jan 12 2025"
        expect(page).to have_content "Reservation Time: 08:00 PM"
        expect(page).to have_content "Table #{table_1.id}"
      end
    end

    it "displays validations for invalid party count and future start time inputs if tried to edit after start time passed" do
      reservation = create(:reservation, party_count: 6, start_time: current_time_top_hour + 2.hours, table_id: table_2.id)

      visit edit_reservation_path(reservation.id)

      within ".edit-reservation-form" do

        travel_to reservation.start_time + 1.minute do
          fill_in "reservation-name", with: "Rena"
          select "8", from: "reservation-party"
          select "2024", from: "reservation-year"
          select "January", from: "reservation-month"
          select "12", from: "reservation-day"
          select "08:00", from: "reservation-time"
          select "PM", from: "am-pm"
          select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
          click_button("Update Reservation")
          expect(page).to have_content 'Start time must be in the future'
          expect(page).to have_content 'Party count is too big for the table capacity'
        end
      end
    end

    it "restricts edit if original start time has passed" do
      reservation = create(:reservation, party_count: 6, start_time: current_time_top_hour + 2.hours, table_id: table_2.id)

      visit edit_reservation_path(reservation.id)

      within ".edit-reservation-form" do

        travel_to reservation.start_time + 1.minute do
          fill_in "reservation-name", with: "Rena"
          select "6", from: "reservation-party"
          select "2028", from: "reservation-year"
          select "January", from: "reservation-month"
          select "12", from: "reservation-day"
          select "08:00", from: "reservation-time"
          select "PM", from: "am-pm"
          select "Table #{table_2.id} - Capacity: 6", from: "reservation-table"
          click_button("Update Reservation")
          expect(page).to have_content "Cannot update reservation as the original start time has passed."
        end
      end
    end
  end
end