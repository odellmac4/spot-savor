require 'rails_helper'

RSpec.describe 'Reservations index' do
  
  describe 'list of reservations' do
    
    let!(:table) {create(:table, capacity: 8)}
    let!(:reservations) {create_list(:reservation, 5, table_id: table.id)}
    let!(:resy_6) {create(:reservation, name: 'Odell', party_count: 7, start_time: Time.zone.local(2024, 12, 24, 10, 0, 0), table_id: table.id)}

    before do
      visit reservations_path
    end

    it 'displays call to action to create a reservation' do
      within ".reservations-index-nav" do
        expect(page).to have_link("Create Reservation", href: new_reservation_path)
      end
    end

    it 'displays total number of reservations' do
      within ".reservations-index-nav" do
        expect(page).to have_content "You have 6 reservations!"
      end
      
      resy_7 = create(:reservation, party_count: 3, table_id: table.id)
      visit reservations_path

      within ".reservations-index-nav" do
        expect(page).to have_content "You have 7 reservations!"
      end
    end

    it 'displays each attribute for a reservation' do
      reservation = reservations.first
      within "#reservation-#{reservation.id}" do
        expect(page).to have_content(reservation.name)
        expect(page).to have_content("Party Count: #{reservation.party_count}")
        expect(page).to have_content("Reservation Date: #{reservation.start_time.strftime("%a, %b %d %Y")}")
        expect(page).to have_content("Reservation Time: #{reservation.start_time.strftime("%I:%M %p")}")
        expect(page).to have_content("Table #{table.id}")
        expect(page).to have_link(href: edit_reservation_path(reservation.id))
        expect(page).to have_link("#{reservation.name}", href: reservation_path(reservation.id))
        expect(page).to have_selector(".delete-reservation-link")
      end

      within "#reservation-#{resy_6.id}" do
        expect(page).to have_content('Odell')
        expect(page).to have_content("Party Count: 7")
        expect(page).to have_content("Reservation Date: Tue, Dec 24 2024")
        expect(page).to have_content("Reservation Time: 10:00 AM")
        expect(page).to have_content("Table #{table.id}")
        expect(page).to have_link(href: edit_reservation_path(resy_6.id))
        expect(page).to have_link("Odell", href: reservation_path(resy_6.id))
        expect(page).to have_selector(".delete-reservation-link")
      end
    end
  end

  describe 'modal to delete reservation' do
    let(:table_1) {create(:table, capacity: 5)}
    let(:table_2) {create(:table, capacity: 6)}
    let(:table_3) {create(:table, capacity: 3)}

    let!(:reservation_1) {create(:reservation, party_count: 5, table_id: table_1.id)}
    let!(:reservation_2) {create(:reservation, party_count: 6, table_id: table_2.id)}
    let!(:reservation_3) {create(:reservation, party_count: 2, table_id: table_3.id)}

    before do
      visit reservations_path
    end

    it 'has reservation name and buttons to delete reservation or cancel request' do
      within "#confirmDeleteModal_#{reservation_1.id}" do
        expect(page).to have_content("Are you sure you want to delete #{reservation_1.name}'s reservation?")
        expect(page).to have_button("Delete")
        expect(page).to have_button("Cancel")
      end
    end

    it 'has a modal to confirm if user wants to destroy reservation' do
      expect(Reservation.exists?(reservation_2.id)).to be_truthy
      within ".reservations-index-nav" do
        expect(page).to have_content "You have 3 reservations!"
      end

      within "#confirmDeleteModal_#{reservation_2.id}" do
        click_button "Delete"
      end

      visit reservations_path
      expect(page).to_not have_content(reservation_2.name)
      expect(page).to have_content(reservation_1.name)
      expect(page).to have_content(reservation_3.name)

      within ".reservations-index-nav" do
        expect(page).to have_content "You have 2 reservations!"
      end

      expect(Reservation.exists?(reservation_2.id)).to be_falsey
    end

    it 'cancels deletion of reservation and allows reservation to persist' do
      within ".reservations-index-nav" do
        expect(page).to have_content "You have 3 reservations!"
      end
      
      within "#confirmDeleteModal_#{reservation_3.id}" do
        click_button "Cancel"
      end

      expect(page).to have_content(reservation_3.name)

      within ".reservations-index-nav" do
        expect(page).to have_content "You have 3 reservations!"
      end

      expect(Reservation.exists?(reservation_3.id)).to be_truthy
    end
  end
end