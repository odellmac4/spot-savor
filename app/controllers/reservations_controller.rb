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
    @reservation = Reservation.new(reservation_params.merge(start_time: reservation_datetime))

    if @reservation.save
      redirect_to reservations_path, notice: "Reservation was successfully created."
    else
      render :new
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def edit
    @reservation = Reservation.find(params[:id])
    @tables = Table.all
  end

  def update
    @reservation = Reservation.find(params[:id])
    @tables = Table.all

    if @reservation.update(reservation_params.merge(start_time: reservation_datetime))
      redirect_to reservation_path(params[:id]),
      notice: "#{@reservation.name}'s reservation was updated successfully"
    else
      render :edit
    end
  end

  def destroy
    reservation = Reservation.find(params[:id])
    if reservation
      reservation.destroy
      redirect_to reservations_path, 
      notice: "#{reservation.name}'s reservation was deleted successfully"
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