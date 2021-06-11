require 'optparse'
require 'date'
params = {}
OptionParser.new do |opts|
  begin
    opts.banner = "Usage: calendar.rb [options]"
    opts.on('-m [month]') {|v| params[:m] = v}
    opts.on('-y [year]') {|v| params[:y] = v}
    opts.version = [0, 1]
    opts.release = "2021-06-11"
    opts.parse!(ARGV)
  rescue OptionParser::InvalidOption => e
    puts "#{opts}"
    exit
  end
end

if params[:m].to_i >= 1 && params[:m].to_i <= 12
  cal_month = params[:m].to_i
else
  cal_month = Date.today.month
end

if params[:y].to_i >= 1970 && params[:y].to_i <= 2100
  cal_year = params[:y].to_i
else
  cal_year = Date.today.year
end

cal_start = Date.new(cal_year, cal_month, 1)
cal_end = Date.new(cal_year, cal_month+1, 1).prev_day

cal_text = "      #{cal_month}月 #{cal_year}\n"
cal_text << "日 月 火 水 木 金 土\n"
cal_text << "   " * cal_start.wday
print cal_text

(cal_start..cal_end).each do |day|
  if day == Date.today
    print"\e[30m\e[47m\e[5m#{day.strftime("%e")}\e[0m "
  else
    print day.strftime("%e ")
  end
  print "\n" if day.saturday?
end
