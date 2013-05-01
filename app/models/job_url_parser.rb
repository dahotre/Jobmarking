require 'open-uri'
require 'readability'
require 'public_suffix'
require 'nokogiri'
require 'sanitize'

class JobUrlParser

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
    @params = generate_params_given_lookup(@lookup)
    @params = fill_blank_params(@params)
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

    if lookup.present?
      job_params[:actual_url] = @uri_source.base_uri.to_s
      Rails.logger.debug "Generating params for : #{lookup.inspect}"
      noko_doc = Nokogiri::HTML(@uri_source) do |config|
        config.noblanks.noent.noerror.nonet
      end

      [:title, :description, :location, :company, :logo].each { |job_attr|
        # If lookup does have corresponding field, parse the doc
        # Else, the corresponding job_param[:field] will remain vacant
        if lookup.send( job_attr.to_s ).present?
          attr_xpath = lookup.send(job_attr.to_s)

          attr_node =
            begin
              noko_doc.at_xpath attr_xpath
            rescue Nokogiri::SyntaxError => se
              Rails.logger.debug "Failed xpath: #{attr_xpath} || URL: #{job_params[:actual_url]} || Other params: #{lookup.inspect}"
              nil
            end

          if attr_node.present?
            if job_attr == :logo
              photo_url = attr_node.attribute('src').content
              job_params[job_attr] = photo_url if photo_url.present?
            else
              job_params[job_attr] = Sanitize.clean(attr_node.content, Sanitize::Config::RESTRICTED)
              .gsub(/\s+/, ' ')
            end
          else
            job_params[job_attr] = nil
          end
        end
      }
    end

    return job_params
  end

  # Attempts to fill in blank job params if any
  def fill_blank_params(params)

    unless all_values_present?(params)
      top_lookups = Lookup.order_by(:other_domain_hits.desc).limit(5)
      top_lookups.each do |top_lookup|
        params = generate_params_given_lookup top_lookup

        break if all_values_present? params

      end

      unless all_values_present?(params)
        params = generate_params_given_lookup(Lookup.new(@@default_lookup_hash))
      end
    end

    return params
  end

  def all_values_present? hash
    hash.reduce (hash.length > 0) do |memo, (k, v)|
      Rails.logger.info "Key : #{k} || Value : #{v}"
      memo && v.present?
    end
  end

  @@default_lookup_hash ||= {
      :title => '//title',
      :location => '//*[@itemprop="jobLocation"]',
      :description => '//*[@itemprop="description"]',
      :company => '//*[@itemprop="name"]',
      :logo => '//*[@itemtype="http://schema.org/JobPosting"]//img'
  }
  
end