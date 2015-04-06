
#require 'ruter'

class TransportsController < ApplicationController

  def index

  end

  def to_minute(input)
    input = DateTime.parse(input)
    hours = input.strftime("%H").to_i
    minutes = input.strftime("%M").to_i
    hours * 60 + minutes
  end

  def to_hour_minute(time)
    time = DateTime.parse(time)
    time = time.strftime("%H:%M")
  end

  def time_difference(time)
    diff_seconds = (time.to_time - Time.now.round).round
    diff_minutes = diff_seconds / 60
  end


  def new

    latlon =  Geocoder.coordinates("Oslo")#("#{params[:from]} Oslo")
    pp latlon
    coordinate = GeoUtm::LatLon.new latlon[0], latlon[1]
    pp coordinate
    utm = coordinate.to_utm
    pp utm
    pp utm.to_lat_lon

    @trip = Transport.new
    departure = Ruter.getPlaceWithName(params[:from])
    departure_place = departure[0]["ID"]
    arrival = Ruter.getPlaceWithName(params[:to])
    arrival_place = arrival[0]["ID"]

    trip = Ruter.getRoute(departure_place, arrival_place)
    trip = trip["TravelProposals"][0]
    pp trip["Stages"].length
    @trip.transfers = trip["Stages"].length
    @trip.departure_place = params[:from]
    @trip.departure_time = to_hour_minute(trip["DepartureTime"])
    @trip.arrival_place = params[:to]
    @trip.arrival_time = to_hour_minute(trip["ArrivalTime"])
    time_diff = time_difference(trip["DepartureTime"].to_time)
    @trip.duration = to_minute(trip["TotalTravelTime"]) + time_diff

    respond_to do |format|
      format.js {}
    end

  end


end


