require 'json'
require 'faraday'
require 'wiringpi'

green = 1
orange = 2
red = 3

green_pin = 4
orange_pin = 17
red_pin = 18

pins = [green_pin, orange_pin, red_pin]

mapping = {5 => green, 4 => green, 3 => orange, 2 => orange, 1 => red}

io = WiringPi::GPIO.new(WPI_MODE_SYS)

pins.each do |pin|
  io.mode(pin, 1)
end

pins.each do |pin|
  io.write(pin,0)
end

while true do
  begin
  level = JSON.parse(Faraday.get("https://devconfive.herokuapp.com/index.json").body).map{|b| b["devcon"]}.min
  #level = [1,2,3,4,5].sample

  puts level

  pins.each do |pin|
    io.write(pin,0)
  end

  case mapping[level]
  when green
    io.write(green_pin,1)
  when orange
    io.write(orange_pin,1)
  when red
    io.write(red_pin,1)
  end 
  sleep(10)
  puts "done sleeping"
  rescue Exception => e
    puts "ERROR: #{e}"
  end
end
