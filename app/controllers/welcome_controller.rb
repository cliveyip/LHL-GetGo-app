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
    url = 'https://getgo-api.herokuapp.com/agencies/GO/routes/' + route_id + '/trips?date=' + date
    response = HTTParty.get(url)
    tripsHash = JSON.parse(response.body)
    tripsArray = tripsHash['trips']

    puts "---------- Task 2a: Trip names ----------"
    tripsArray.each do |trip|
      puts trip['id']
    end

    # https://getgo-api.herokuapp.com/agencies/GO/routes/258-MI/trips/6239-Fri-167/stop_times

    # Second, from the first trip, get the stops
    # ASSUMPTION: any given trip for the same route (or route variant) always returns the same stops
    # so we can just pick any trip (the first trip) from the route to obtain the stops
    trip_id_first = tripsArray[0]['id']
    url = 'https://getgo-api.herokuapp.com/agencies/GO/routes/' + route_id + '/trips/' + trip_id_first + '/stop_times'
    response = HTTParty.get(url)
    stopTimesHash = JSON.parse(response.body)
    stopTimesArray = stopTimesHash['stop_times']

    puts "---------- Task 2b: Stops stop_id ----------"
    stopTimesArray.each do |stopTime|
      puts stopTime['stop_id']
    end

    # TODO: Third, get the stop_names from stop_id

    # TODO: do route variant for buses (current solution only for trains)

    # Task 3. Get stop_times from stops and date and time

    # byebug;
  end
end
