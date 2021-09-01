
module ReportDates

  def last_week
    week(date: (Date.today - 7 * 20))
  end

  def week_range(date:)
    m = monday(date: date)
    (m..friday(monday: m))
  end

  def monday(date:)
    date - date.wday + 1
  end

  def friday(monday:)
    monday + 4
  end

end