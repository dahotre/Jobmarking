require 'public_suffix'
require 'open-uri'

class Lookup
  include Mongoid::Document
  include Mongoid::Timestamps

  field :example_page
  field :domain
  field :company
  field :title
  field :description
  field :location
  field :logo
  field :other_domain_hits, type: Integer
  field :is_deleted, type: Boolean, default: false

  field :destroy_notices, type: Array

  before_save :generate_domain

  validates_presence_of :example_page, :title, :description, :location
  validates_format_of :example_page, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix
  
  #scope :active, where( domain: /[^(_d)]$/i )
  scope :active, where( is_deleted: false )

  #scope :inactive, where( domain: /[(_d)]$/i )
  scope :inactive, where( is_deleted: true )

  protected
  def generate_domain
    self.domain ||= PublicSuffix.parse(URI.parse( self.example_page ).host).sld.downcase if self.example_page.present?
  end
  
end
