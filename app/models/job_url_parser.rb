require 'open-uri'
require 'readability'
require 'public_suffix'
require 'nokogiri'
require 'sanitize'

class JobUrlParser
  @@default_lookup_hash ||= {
      :title => '//*[@itemprop="title"]',
      :location => '//*[@itemprop="jobLocation"]',
      :description => '//*[@itemprop="description"]',
      :company => '//*[@itemprop="name"]',
      :photo => '//*[@itemtype="http://schema.org/JobPosting"]//img'
  }

  def initialize (url)
    @url = url
    uri = URI.parse(@url)
    @uri_source = uri.read
  end

  # Finds a Lookup that matches the domain of the initialized job url
  # and parses the source HTML of the url with reference to XPath variables
  # of the Lookup object
  #
  # @return [Hash] of Job attributes
  def job_params

    #  Get domain_details
    domain_details = PublicSuffix.parse @uri_source.base_uri.host
    Rails.logger.debug "Domain for #{@uri_source.base_uri.to_s} => #{domain_details}"

    #  get corresponding lookup
    if domain_details.sld.present?
      @lookup ||= Lookup.find_by(domain: domain_details.sld)
    end

    #  get params hash given uri_source & lookup
    @params = generate_params_given_lookup(@lookup) if @lookup.present?

    @params[:description] ||= Readability::Document.new(@uri_source).content
    return @params
  end

  # Given a Lookup , parses the source HTML of the initialized job url with reference
  # to XPath variables of the Lookup object
  #
  # @param [Lookup] lookup
  # @return [Hash] of Job attributes
  def generate_params_given_lookup(lookup)
    job_params ||= Hash.new

    job_params[:actual_url] = @uri_source.base_uri.to_s
    Rails.logger.debug "Generating params for : #{lookup.inspect}"
    noko_doc = Nokogiri::HTML(@uri_source) do |config|
      config.noblanks.noent.noerror.nonet
    end

    [:title, :description, :location, :company, :logo].each { |job_attr|
      attr_xpath = lookup.send( job_attr.to_s ).present? ? lookup.send(job_attr.to_s)
                    : @@default_lookup_hash[ job_attr ]
      attr_node = noko_doc.at_xpath attr_xpath

      if attr_node.present?
        if job_attr == :logo
          photo_url = attr_node.attribute('src').content
          job_params[job_attr] = photo_url if photo_url.present?
        else
          job_params[job_attr] = Sanitize.clean(attr_node.content, Sanitize::Config::RESTRICTED)
          .gsub(/\s+/, ' ')
        end
      end
    }

    Rails.logger.debug "Title node set : #{job_params.inspect}"

    return job_params
  end
  
end