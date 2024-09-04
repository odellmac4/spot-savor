class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new
    @tables = Table.all
  end
  
  def index
    @reservations = Reservation.all
  end
  
  
  def create
    @tables = Table.all
    @am_pm = datetime_params[:am_pm]
    @reservation = Reservation.new(reservation_params.merge(start_time: reservation_datetime))

    if @reservation.save
      redirect_to reservations_path, notice: "Reservation was successfully created."
    else
      render :new
    end
  end

  private

  def reservation_params
    params.require(:reservation).permit(
      :name,
      :party_count,
      :table_id
    )
  end

  def datetime_params
    params.require(:reservation).permit(
      :reservation_year,
      :reservation_month,
      :reservation_day,
      :reservation_time,
      :am_pm
    )
  end

  def reservation_datetime
    date = "#{datetime_params[:reservation_month]} #{datetime_params[:reservation_day]} #{datetime_params[:reservation_year]}"
    time = "#{datetime_params[:reservation_time]} #{datetime_params[:am_pm]}"
    reservation_datetime = "#{date} #{time}"
    DateTime.strptime(reservation_datetime, '%B %d %Y %I:%M %p')
  end
  
end