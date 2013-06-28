require 'open-uri'

class GeocodeTask
  @@mapquest_url = 'http://open.mapquestapi.com/geocoding/v1/address?callback=renderGeocode&maxResults=1&thumbMaps=true&key='
  @@gmaps_url = 'http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address='
#status
#location
  def initialize(param)
    if param.is_a? Job
      @location = param.location
    else
      @location = param
    end
  end

  def perform(limit=2)
    #URI.parse(@@mapquest_url + ENV['MAPQUEST_KEY'] + "&location=#{URI::encode(@location)}").read
    if limit > 0
      result = JSON.parse(URI.parse(@@gmaps_url + "#{URI::encode(@location)}").read)
      if (result['status'] == 'OK' && result['results'].length >= 1 )
         return (result['results'][0]['geometry']['location']).values_at('lng', 'lat')
      elsif (result['status'] == 'UNKNOWN_ERROR')
        perform(--limit)
      else
        Longo.create( :level => 'ERROR', :reason => 'Geocode error', :location => @location, :result => result, :t => DateTime.now.strftime )
      end
    else
      Longo.create( :level => 'ERROR', :reason => 'Geocode error', :location => @location, :t => DateTime.now.strftime)
    end

    return nil

  end

end