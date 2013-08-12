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
  io.write(pin,1)
end

errors = 0
max_errors = 5

while true do
  begin
  conn = Faraday.new(:url => "https://devconfive.herokuapp.com/index.json")
  response = conn.get do |req|
    req.options[:timeout] = 5
    req.options[:open_timeout] = 2 
  end
  level = JSON.parse(response.body).map{|b| b["devcon"]}.min
  #level = [1,2,3,4,5].sample

  puts level

  pins.each do |pin|
    io.write(pin,1)
  end

  case mapping[level]
  when green
    io.write(green_pin,0)
  when orange
    io.write(orange_pin,0)
  when red
    io.write(red_pin,0)
  end 
  sleep(10)
  puts "done sleeping"
  errors = 0
  rescue StandardError => e
    puts "ERROR: #{e}"
    errors++
    if errors > max_errors
      pins.each do |pin|
        io.write(pin, 1)
      end
    end
  rescue Interrupt => i
    puts "Shutting down"
    pins.each do |pin|
      io.write(pin, 1)
    end
    raise i
  end
end
