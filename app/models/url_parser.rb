require 'open-uri'
require 'readability'

class UrlParser
  def initialize (url)
    @url = url
    @params = Hash.new
  end
  
  def job_params
    uri = URI.parse(@url)
    source = uri.read
    @params[:actual_url] = source.base_uri.to_s
    @params[:description] = Readability::Document.new(source).content
    return @params
  end
  
end