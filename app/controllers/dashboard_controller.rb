class DashboardController < ApplicationController
  def index
    @reservations = Reservation.all
  end
end