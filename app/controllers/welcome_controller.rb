class WelcomeController < ApplicationController
  # Run this on http://localhost:3000/welcome/index
  def index
    # ----- Task 1. Get all route names -----
    routes = getRoutes
    @route_values = []
    routes.each do |route|
      name_and_id = []
      name_and_id += [route['long_name'], route['id']]
      @route_values << name_and_id
    end

    # ----- Task 2. Get stops from route and date -----
    date = '20161202'
    route_id = '258-21'
    route_variant = '21D'
    stops = getStops(getTrips(date, route_id, route_variant)[0])
    @stop_values = []
    stops.each do |stop|
      name_and_id = []
      name_and_id += [stop['name'], stop['id']]
      @stop_values << name_and_id
    end

    # ----- Task 3. Get stop_times from toStop, fromStop, date, and time -----
    toStop = "01436"    # "Streetsville GO Station Parking Lot"
    fromStop = "USBT"   # "Union Station Bus Terminal"
    date = '20161202'
    route_id = '258-21'
    route_variant = '21D'

    # getArrivalTimes(date, route_id, route_variant, toStop, fromStop)
  end

  def something
    byebug
  end
  # helper functions
  def getRoutes
    routeNames = []
    url = 'https://getgo-api.herokuapp.com/agencies/GO/routes/'
    response = HTTParty.get(url)
    routesHash = JSON.parse(response.body)
    routesArray = routesHash['routes']

    puts "---------- Task 1: Route names ----------"
    routesArray.each do |route|
      routeNames << route
    end
    return routeNames
  end

  def getRouteVariants (route_id)
    # TODO
  end

  def getTrips (date, route_id, route_variant)
    #  First, get all the trips
    url = 'https://getgo-api.herokuapp.com/routes/' + route_id + '/trips?date=' + date
    # https://getgo-api.herokuapp.com/routes/258-MI/trips?date=20161202
    response = HTTParty.get(url)
    tripsHash = JSON.parse(response.body)
    tripsArray = tripsHash['trips']

    tripsWithCorrectVariant = tripsArray.find_all {
      |trip| trip['route_variant'] == route_variant
    }

    puts "---------- Task 2a: Trips under the specified route variant ----------"
    tripsWithCorrectVariant.each do |trip|
      print "Trip_id: ", trip['id'], ",  Route Variant: ", + trip['route_variant'] + ",  Direction: " + trip['direction_id'] + "\n"
    end

    return tripsWithCorrectVariant
  end

  def getStops (trip)
    # Second, from the first trip, get the stops
    # ASSUMPTION: any given trip for the same route variant always returns the same stops
    # so we can just pick any trip (the first trip) from the route variant to obtain the stops
    url = 'https://getgo-api.herokuapp.com/' + '/trips/' + trip['id'] + '/stops'
    # https://getgo-api.herokuapp.com/trips/6179-Fri-21865/stops
    response = HTTParty.get(url)
    stopsHash = JSON.parse(response.body)
    stopsArray = stopsHash['stops']

    stopNames = []
    puts "---------- Task 2b: Stops names under the specified route variant ----------"
    stopsArray.each do |stop|
      stopNames << stop
    end

    return stopNames
    # TODO: order the stop names in order of stop sequence (need stop_times table for this)
  end

  def getDirection (trip, toStop, fromStop)

    url = 'https://getgo-api.herokuapp.com/' + '/trips/' + trip['id']
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

    return direction_id
  end

  def getArrivalTimes (date, route_id, route_variant, toStop, fromStop)

    tripsArray = getTrips(date, route_id, route_variant)

    direction_id = getDirection(tripsArray[0], toStop, fromStop)

    # get the stop_times from these trips

    puts "---------- Task 3a: direction ----------"
    puts "direction_id = " + direction_id.to_s

    # Second, get all the trips with the correct direction_id
    tripsWithCorrectDirection = tripsArray.find_all {
      |trip| trip['direction_id'] == direction_id.to_s
    }

    puts "---------- Task 3b: trips with correct direction_id ----------"
    # puts tripsWithCorrectDirection

    departureTimes = [];
    # Third, for each trip, get the departure_time for the desired stop (by referencing stop_id)
    tripsWithCorrectDirection.each do |trip|
      url = 'https://getgo-api.herokuapp.com/' + '/trips/' + trip['id'] + '/stop_times'
      # https://getgo-api.herokuapp.com/trips/6239-Fri-167/stop_times
      response = HTTParty.get(url)
      stopTimesHash = JSON.parse(response.body)
      stopTimesArray = stopTimesHash['stop_times']
      departureTimes << stopTimesArray.find { |st| st['stop_id'] == fromStop}['departure_time']
    end


    puts "---------- Task 3c: departure times ----------"
    puts departureTimes
    # ["08:45:00", "08:18:00", "08:06:00", "07:56:00", "07:45:00", "07:33:00", "07:20:00", "07:03:00", "06:42:00", "06:18:00"]

    # Fourth, compare with current time

    # Time.now.getlocal("-05:00")

    # TODO: take care of bus routes that replace trains in non-rush hours (e.g. Bus 21 for Milton Train)
    # TODO: test other train route

  end
end
