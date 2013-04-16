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
      :company => '//*[@itemprop="name"]'
  }

  def initialize (url)
    @url = url
  end
  
  def job_params
    uri = URI.parse(@url)
    source = uri.read

    # TODO Get domain_details
    domain_details = PublicSuffix.parse source.base_uri.host
    Rails.logger.debug "Domain for #{source.base_uri.to_s} => #{domain_details}"

    # TODO get corresponding lookup
    if domain_details.sld.present?
      @lookup ||= Lookup.find_by(domain: domain_details.sld)
    end

    # TODO get params hash given uri_source & lookup
    @params = generate_params(source, @lookup) if @lookup.present?

    @params[:description] ||= read_from_readability source
    return @params
  end

  def read_from_readability(uri_source)
    Readability::Document.new(uri_source).content
  end

  def generate_params(uri_source, lookup)
    job_params ||= Hash.new

    job_params[:actual_url] = uri_source.base_uri.to_s
    Rails.logger.debug "Generating params for : #{lookup.inspect}"
    noko_doc = Nokogiri::HTML(uri_source) do |config|
      config.noblanks.noent.noerror.nonet
    end

    [:title, :description, :location, :company].each { |job_attr|
      attr_xpath = lookup.send( job_attr.to_s ).present? ? lookup.send(job_attr.to_s)
                    : @@default_lookup_hash[ job_attr ]
      attr_node = noko_doc.at_xpath attr_xpath

      if attr_node.present?
        job_params[job_attr] = Sanitize.clean(attr_node.content, Sanitize::Config::RESTRICTED)
          .gsub(/\s+/, ' ')
      end
    }

    Rails.logger.debug "Title node set : #{job_params.inspect}"

    return job_params
  end
  
end