class WelcomeController < ApplicationController
  def index

    # Run this on http://localhost:3000/welcome/index

    # ----- Task 1. Get all route names -----
    url = 'https://getgo-api.herokuapp.com/agencies/GO/routes/'
    response = HTTParty.get(url)
    routesHash = JSON.parse(response.body)
    routesArray = routesHash['routes']

    puts "---------- Task 1: Route names ----------"
    routesArray.each do |route|
      puts route['long_name']
    end

    # ----- Task 2. Get stops from route and date -----

    # User supplies the route and date
    # TODO: get route_id from long_name
    date = '20161202'
    route_id = '258-MI'

    #  First, get all the trips
    url = 'https://getgo-api.herokuapp.com/routes/' + route_id + '/trips?date=' + date
    # https://getgo-api.herokuapp.com/routes/258-MI/trips?date=20161202
    response = HTTParty.get(url)
    tripsHash = JSON.parse(response.body)
    tripsArray = tripsHash['trips']

    puts "---------- Task 2a: Trip names ----------"
    tripsArray.each do |trip|
      puts trip['id']
    end

    # Second, from the first trip, get the stops
    # ASSUMPTION: any given trip for the same route (or route variant) always returns the same stops
    # so we can just pick any trip (the first trip) from the route to obtain the stops
    trip_id_first = tripsArray[0]['id']
    # https://getgo-api.herokuapp.com/trips/6239-Fri-167/stops
    url = 'https://getgo-api.herokuapp.com/' + '/trips/' + trip_id_first + '/stops'
    response = HTTParty.get(url)
    stopsHash = JSON.parse(response.body)
    stopsArray = stopsHash['stops']

    puts "---------- Task 2b: Stops names ----------"
    stopsArray.each do |stop|
      puts stop['name']
    end


    # TODO: do route variant for buses (current solution only for trains)

    # ----- Task 3. Get stop_times from toStop, fromStop, date, and time -----
    toStop = "UN"
    fromStop = "SR"
    date = '20161202'
    route_id = '258-MI'
    direction_id = 999  # To be determined

    # First, determine the direction based on toStop and fromStop
    # Use tripsArray obtained from previous step i.e. "6239-Fri-167", "6239-Fri-166"... "6239-Fri-148"
    # pick the first two trips from the array, since each one represents one direction
    # tripsArray[0] = "6239-Fri-167" is from Union (stop_sequence = 1) to Milton (stop_sequence = 9)
    # tripsArray[1] = "6239-Fri-166" is from Milton (stop_sequence = 1) to Union (stop_sequence = 9)

    url = 'https://getgo-api.herokuapp.com/' + '/trips/' + tripsArray[0]['id']
    # https://getgo-api.herokuapp.com/trips/6239-Fri-167/stop_times
    response = HTTParty.get(url)
    stopTimesHash = JSON.parse(response.body)
    stopTimesArray = stopTimesHash['stops']

    # stopTimesHash['trip']['direction_id']  # "1"
    # stopTimesHash['trip']['stops'].class  # array
    # stopTimesHash['trip']['stops'].find { |s| s['id'] == 'UN' }  # {"id"=>"UN", "name"=>"Union Station", ...}
    # stopTimesHash['trip']['stop_times'].class  # array
    toStop_sequence = stopTimesHash['trip']['stop_times'].find { |st| st['stop_id'] == toStop}['stop_sequence'] #1
    fromStop_sequence = stopTimesHash['trip']['stop_times'].find { |st| st['stop_id'] == fromStop}['stop_sequence'] #6

    if fromStop_sequence < toStop_sequence
       direction_id = stopTimesHash['trip']['direction_id'].to_i
    else
       direction_id = 1 - stopTimesHash['trip']['direction_id'].to_i # swapping 0 and 1
    end

    # get the stop_times from these trips

    puts "---------- Task 3a: direction ----------"
    puts "direction_id = " + direction_id.to_s

    # Second, get all the trips with the correct direction_id
    tripsArray.find {
      |trip| trip['direction_id'] == direction_id
    }


    # Third, for each trip, get the departure_time for the desired stop (by referecning stop_sequence)


    # Fourth, compare with current time

    # Time.now.getlocal("-05:00")

    # TODO: take care of bus routes that replace trains in non-rush hours (e.g. Bus 21 for Milton Train)
    # TODO: test other train route

    byebug;
  end
end
