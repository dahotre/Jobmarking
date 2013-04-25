require 'open-uri'

class GeocodeTask
  @@mapquest_url = 'http://open.mapquestapi.com/geocoding/v1/address?callback=renderGeocode&maxResults=1&thumbMaps=true&key='
#status
#location
  def initialize(param)
    if param.is_a? Job
      @location = param.location
    else
      @location = param
    end
  end

  def perform
    result = URI.parse(@@mapquest_url + ENV['MAPQUEST_KEY'] + "&location=#{URI::encode(@location)}").read
  end

end
