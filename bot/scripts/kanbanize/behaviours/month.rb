class Month

  def self.range(month:, year: Date.today.year)
    first_day = Date.civil(year,month,1)
    last_day = Date.civil(year, month + 1, 1) - 1
    (first_day..last_day)
  end

end