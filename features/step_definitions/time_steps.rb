Given(/^it is (\d+):(\d+):(\d+) on (\d+)\/(\d+)\/(\d+)$/) do |hour, minute, second, month, day, year|
  hour, minute, second = hour.to_i, minute.to_i, second.to_i
  month, day, year = month.to_i, day.to_i, year.to_i
  @time = DateTime.civil year, month, day, hour, minute, second
  # Time.stub(:now).and_return @time

  BotAway::ParamParser.any_instance.stub(:current_time).and_return @time
  BotAway::Spinner.any_instance.stub(:current_time).and_return @time
end
