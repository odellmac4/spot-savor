module ApplicationHelper
  def format_date(date)
    date.strftime("%a, %b %d %Y")
  end

  def format_time(time)
    time.in_time_zone(Time.zone).strftime("%I:%M %p")
  end

  def time_options
    start_time = Time.zone.parse('12:00')
    end_time = start_time + 11.hours

    options = []
    current_time = start_time

    while current_time <= end_time
      options << [current_time.strftime('%I:%M'), current_time.strftime('%I:%M')]
      current_time += 1.hours
    end

    options
  end

  def year_options
    start_year = Time.now.year
    end_year = start_year + 5
    options = (start_year..end_year).to_a.map{|year| [year, year]}
  end

  def month_options
    months = Date::MONTHNAMES.compact
    options = months.map{|month| [month, month]}
  end

  def table_options(tables)
    if tables.present?
      tables.map { |table| ["Table #{table.id} - Capacity: #{table.capacity}", table.id] }
    else
      [["No tables available", ""]]
    end
  end

  def month_name(month_num)
    Date::MONTHNAMES.compact[month_num - 1]
  end

  def hour_minutes(time)
    time.in_time_zone(Time.zone).strftime('%I:%M')
  end

  def am_pm(reservation)
    reservation.start_time ? reservation.start_time.in_time_zone(Time.zone).strftime("%p") : nil
  end

  def prefill_year(reservation)
    reservation.start_time ? reservation.start_time.year : nil
  end

  def prefill_month(reservation)
    reservation.start_time ? month_name(reservation.start_time.month) : nil
  end

  def prefill_day(reservation)
    reservation.start_time ? reservation.start_time.day : nil
  end

  def prefill_time(reservation)
    reservation.start_time ? hour_minutes(reservation.start_time) : nil
  end

  def reservation_rush_times(times)
    if times.length == 2
      "#{times[0]} and #{times[1]}"
    else
      times[0]
    end
  end

end
